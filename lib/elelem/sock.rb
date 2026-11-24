# frozen_string_literal: true

require "socket"

module Elelem
  class Sock
    OWNER_ONLY = 0o177
    private_constant :OWNER_ONLY

    def initialize(path)
      @path = path
      @server = listen
      @clients = Queue.new
    end

    def print(text) = @client.print(text)
    def gets = @client.gets

    def each_client(&)
      Thread.new { loop { admit(@server.accept) } }
      loop { serve(@clients.pop, &) }
    ensure
      File.delete(@path)
    end

    private

    def listen
      UNIXSocket.new(@path).close
      raise "#{@path}: already running"
    rescue Errno::ENOENT, Errno::ECONNREFUSED
      File.delete(@path) if File.socket?(@path)
      File.umask(OWNER_ONLY).then { |umask| UNIXServer.new(@path).tap { File.umask(umask) } }
    end

    def admit(client)
      return @clients << (@client = client) unless busy?

      client.puts "busy"
      client.close
    rescue SystemCallError
      nil
    end

    def busy? = @client && !@client.closed?

    def serve(client)
      yield
    rescue Errno::EPIPE, Errno::ECONNRESET
      nil
    ensure
      client.close
    end
  end

  class SockInput < Input
    def ask(prompt)
      @stream.print(prompt)
      @stream.gets&.strip
    end

    def interactive? = true
  end
end
