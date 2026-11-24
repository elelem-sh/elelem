# frozen_string_literal: true

require "elelem/cli"

RSpec.describe Elelem::Sock, if: !Gem.win_platform? do
  around do |example|
    Dir.mktmpdir do |dir|
      @path = File.join(dir, "elelem.sock")
      example.run
    ensure
      @server&.kill&.join
    end
  end

  def serve(provider = FakeProvider.new, toolbox: Elelem::Toolbox.new)
    sock = described_class.new(@path)
    agent = Elelem::Agent.new(provider, toolbox: toolbox, output: Elelem::Output.new(stream: sock))
    session = Elelem::Session.new(agent, input: Elelem::SockInput.new(stream: sock))
    @server = Thread.new { sock.each_client { Elelem::Repl.new(session).run } }
    session
  end

  def ask(line)
    UNIXSocket.open(@path) do |client|
      next "busy" if client.gets == "busy\n"

      client.puts line
      client.close_write || client.read
    end
  end

  def asking_first(answers)
    toolbox = Elelem::Toolbox.new
    session = serve(FakeProvider.calling("guarded"), toolbox: toolbox)
    toolbox.add("guarded", description: "asks first") { (answers << session.input.ask("Allow? ")) && {} }
    session
  end

  it "serves the session with --sock PATH and asks it with --sock PATH and a prompt" do
    @server = Thread.new { Elelem::CLI.new(["--sock", @path]).run }
    sleep 0.01 until File.socket?(@path)

    expect { Elelem::CLI.new(["--sock", @path, "echo", "hi"]).run }
      .to output(/\Aelelem v.*^hi$.*exit 0/m).to_stdout
  end

  it "binds a socket that only its owner can use, and removes it on exit" do
    serve

    expect(File.stat(@path).mode & 0o777).to eq(0o600)
    ask("hello")
    @server.kill.join
    expect(File.exist?(@path)).to be(false)
  end

  it "replaces a socket that nothing listens on" do
    UNIXServer.new(@path).close
    serve

    expect(ask("hello")).to include("ok")
  end

  it "refuses to bind a socket that is already served" do
    serve

    expect { described_class.new(@path) }.to raise_error(/already running/)
  end

  it "keeps the conversation across connections" do
    session = serve
    2.times { ask("hello") }

    expect(session.conversation.to_a.count { |message| message[:role] == "user" }).to eq(2)
  end

  it "tells a second client it is busy and closes it" do
    serve
    UNIXSocket.open(@path) do |first|
      first.gets

      expect(UNIXSocket.open(@path, &:read)).to eq("busy\n")
    end
  end

  it "keeps serving after a client hangs up during a turn" do
    hung_up = Queue.new
    provider = FakeProvider.new
    provider.define_singleton_method(:fetch) { |*args, &block| hung_up.pop && super(*args, &block) }
    serve(provider)
    UNIXSocket.open(@path) { |client| client.puts "hello" }
    2.times { hung_up << true }
    sleep 0.01 while (reply = ask("again")) == "busy"

    expect(reply).to include("ok")
  end

  it "is interactive, so a tool asks the client before it acts" do
    answers = []
    asking_first(answers)
    UNIXSocket.open(@path) do |client|
      client.puts "go"
      client.gets("Allow? ")
      client.puts "y"
      client.close_write
      client.read
    end

    expect(answers).to eq(["y"])
  end

  it "answers nil, a refusal, when the client has half-closed" do
    answers = []
    session = asking_first(answers)

    expect([ask("go"), answers, session.input.interactive?]).to match([/Allow\? /, [nil], true])
  end
end
