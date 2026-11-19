# frozen_string_literal: true

require "elelem/http"
require "socket"

RSpec.describe Elelem::HTTP do
  # Answers each request with the next reply. A :hang_up after a reply closes
  # the connection, as a server does when a keep-alive connection idles out.
  let(:server_class) do
    Class.new do
      attr_reader :connections, :requests, :last_request

      def initialize(replies)
        @replies = replies
        @connections = 0
        @requests = 0
        @server = TCPServer.new("127.0.0.1", 0)
        @thread = Thread.new { loop { serve(@server.accept) } }
      end

      def uri = URI("http://127.0.0.1:#{@server.addr[1]}/v1/chat")

      def stop
        @thread.kill
        @server.close
      end

      private

      def serve(socket)
        @connections += 1
        answer(socket) while !socket.closed? && read_request(socket)
      ensure
        socket.close
      end

      def answer(socket)
        @requests += 1
        socket.write(@replies.shift)
        socket.close if @replies.first == :hang_up && @replies.shift
      end

      def read_request(socket)
        head = socket.gets("\r\n\r\n") or return
        @last_request = head + socket.read(head[/content-length: (\d+)/i, 1].to_i)
      end
    end
  end

  def reply(status, body, headers = {})
    head = headers.merge("content-length" => body.bytesize).map { |k, v| "#{k}: #{v}\r\n" }.join
    "HTTP/1.1 #{status} Status\r\n#{head}\r\n#{body}"
  end

  def serve(*replies)
    @server = server_class.new(replies)
  end

  after { @server&.stop }

  subject(:client) { described_class.new(open_timeout: 1, read_timeout: 5) }

  before { allow(client).to receive(:sleep) }

  def post(body = { q: 1 })
    seen = nil
    client.post(@server.uri, body:) { |response| seen = response.read_body }
    seen
  end

  describe "#post" do
    it "sends JSON and the given headers" do
      serve(reply(200, "ok"))
      seen = nil
      client.post(@server.uri, body: { q: 1 }, headers: { "x-api-key" => "k" }) { |r| seen = r.read_body }
      expect(seen).to eq("ok")
      expect(@server.last_request.downcase).to include("x-api-key: k", "content-type: application/json", '{"q":1}')
    end

    it "reuses one connection for requests in a row" do
      serve(reply(200, "a"), reply(200, "b"))
      expect([post, post]).to eq(%w[a b])
      expect(@server.connections).to eq(1)
    end

    it "reconnects when the server closed the idle connection" do
      serve(reply(200, "a"), :hang_up, reply(200, "b"))
      expect([post, post]).to eq(%w[a b])
      expect(@server.connections).to eq(2)
    end

    it "retries a busy server after the wait it asks for" do
      serve(reply(529, "overloaded", "retry-after" => "3"), reply(200, "ok"))
      expect(post).to eq("ok")
      expect(client).to have_received(:sleep).with(3.0)
    end

    it "backs off when the server names no wait" do
      serve(reply(429, "slow down"), reply(503, "oops"), reply(200, "ok"))
      expect(post).to eq("ok")
      expect(client).to have_received(:sleep).with(1).ordered
      expect(client).to have_received(:sleep).with(2).ordered
    end

    it "gives up after its retries" do
      serve(reply(529, "a"), reply(529, "b"), reply(529, "overloaded"))
      expect { post }.to raise_error(RuntimeError, "HTTP 529: overloaded")
      expect(@server.requests).to eq(3)
    end

    it "does not wait longer than it would for an answer" do
      serve(reply(429, "slow down", "retry-after" => "600"))
      expect { post }.to raise_error(RuntimeError, /HTTP 429: busy for 600.0s/)
      expect(client).not_to have_received(:sleep)
    end

    it "logs why the server was busy" do
      allow(Elelem.logger).to receive(:warn)
      serve(reply(529, "overloaded"), reply(200, "ok"))
      post
      expect(Elelem.logger).to have_received(:warn).with("http: HTTP 529: overloaded; retrying in 1s")
    end

    it "does not retry a request the server rejects" do
      serve(reply(400, "bad request"))
      expect { post }.to raise_error(RuntimeError, "HTTP 400: bad request")
      expect(@server.requests).to eq(1)
    end

    it "does not retry once the reply is handed over, so no output repeats" do
      serve(reply(200, "a"), reply(200, "b"))
      expect { client.post(@server.uri, body: {}) { raise Errno::ECONNRESET } }.to raise_error(Errno::ECONNRESET)
      expect(@server.requests).to eq(1)
    end

    it "starts a fresh connection after a reply that was not read to the end" do
      serve(reply(200, "a"), reply(200, "b"))
      expect { client.post(@server.uri, body: {}) { raise Interrupt } }.to raise_error(Interrupt)
      expect(post).to eq("b")
      expect(@server.connections).to eq(2)
    end

    it "does not retry when nothing listens, so a stopped local server fails fast" do
      port = TCPServer.open("127.0.0.1", 0) { |s| s.addr[1] }
      expect { client.post(URI("http://127.0.0.1:#{port}/"), body: {}) {} }.to raise_error(Errno::ECONNREFUSED)
      expect(client).not_to have_received(:sleep)
    end
  end

  describe ".lines and .events" do
    def response(*chunks)
      double(read_body: nil).tap do |r|
        allow(r).to receive(:read_body) { |&block| chunks.each(&block) }
      end
    end

    it "yields lines split across chunks, with CRLF and no final newline" do
      lines = []
      described_class.lines(response("{\"a\":1}\r\n\r\n{\"b\"", ":2}\n{\"c\":3}")) { lines << it }
      expect(lines).to eq(['{"a":1}', '{"b":2}', '{"c":3}'])
    end

    it "skips empty chunks" do
      lines = []
      described_class.lines(response("", "a\n", "", "b")) { lines << it }
      expect(lines).to eq(%w[a b])
    end

    it "skips events with no data, such as keep-alives" do
      events = []
      described_class.events(response("data:\n\ndata: {\"a\":\"[DONE]\"}\n\n")) { events << it }
      expect(events).to eq(['{"a":"[DONE]"}'])
    end

    it "yields the data of each event and skips the rest" do
      stream = "event: ping\r\ndata: {\"a\":1}\r\n\r\n: comment\ndata:{\"b\":2}\n\ndata: [DONE]\n\n"
      events = []
      described_class.events(response(stream[0, 17], stream[17..])) { events << it }
      expect(events).to eq(['{"a":1}', '{"b":2}'])
    end
  end
end
