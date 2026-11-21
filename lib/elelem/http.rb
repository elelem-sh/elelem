# frozen_string_literal: true

require "json"
require "net/http"

module Elelem
  # A keep-alive client for providers that stream their replies.
  # Before a reply arrives it retries busy servers and broken connections.
  # Once the caller has the reply it never retries, so no output repeats.
  # One request at a time: give each provider its own client.
  class HTTP
    BROKEN = [Net::OpenTimeout, Errno::ECONNRESET, Errno::EPIPE, EOFError].freeze
    BUSY = %w[429 500 502 503 504 529].freeze
    KEEP_ALIVE = 30
    LONGEST_WAIT = 30

    class Busy < StandardError
      attr_reader :wait

      def initialize(reply, wait)
        @wait = wait
        super("HTTP #{reply.code}: #{reply.body}")
      end
    end

    def self.lines(response, &)
      rest = response_lines(response, &)
      complete_lines("#{rest}\n", &)
    end

    # The data of each server-sent event.
    def self.events(response)
      lines(response) do |line|
        data = line.delete_prefix("data:").strip if line.start_with?("data:")
        yield data unless data.nil? || data.empty? || data == "[DONE]"
      end
    end

    def self.response_lines(response, &)
      rest = +""
      response.read_body { |chunk| rest = complete_lines(rest + chunk, &) }
      rest
    end

    # Yields each complete, non-blank line and returns the incomplete rest.
    def self.complete_lines(text)
      complete, _, rest = text.rpartition("\n")
      complete.split("\n").map(&:strip).each { |line| yield line unless line.empty? }
      rest
    end
    private_class_method :response_lines, :complete_lines

    def initialize(read_timeout: 3600, open_timeout: 10, retries: 2)
      @options = { read_timeout:, open_timeout:, keep_alive_timeout: KEEP_ALIVE }
      @retries = retries
    end

    def post(uri, body:, headers: {}, &)
      request = Net::HTTP::Post.new(uri, { "content-type" => "application/json", **headers })
      request.body = JSON.generate(body)
      deliver(uri, request, 0, &)
    end

    private

    def deliver(uri, request, attempt, &)
      exchange(uri, request, attempt, &)
    rescue Busy, *BROKEN => e
      raise if @replied || attempt >= @retries

      pause(e.is_a?(Busy) ? e.wait : 2**attempt, e)
      deliver(uri, request, attempt + 1, &)
    end

    def exchange(uri, request, attempt, &)
      @replied = false
      response = connection(uri).request(request) { |reply| hand_over(reply, attempt, &) }
    ensure
      disconnect unless response
    end

    def hand_over(reply, attempt)
      check(reply, attempt)
      @replied = true
      yield reply
    end

    def check(reply, attempt)
      return if reply.is_a?(Net::HTTPSuccess)
      raise Busy.new(reply, wait_for(reply, attempt)) if BUSY.include?(reply.code) && attempt < @retries

      raise "HTTP #{reply.code}: #{reply.body}"
    end

    def wait_for(reply, attempt)
      seconds = Float(reply["retry-after"], exception: false) || (2**attempt)
      raise "HTTP #{reply.code}: busy for #{seconds}s, try again later" if seconds > LONGEST_WAIT

      seconds
    end

    def pause(seconds, error)
      Elelem.logger.warn("http: #{error.message}; retrying in #{seconds}s")
      sleep(seconds)
    end

    def connection(uri)
      disconnect unless @connection&.started? && [@connection.address, @connection.port] == [uri.host, uri.port]
      @connection ||= Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", **@options)
    end

    def disconnect
      @connection.finish if @connection&.started?
      @connection = nil
    end
  end
end
