# frozen_string_literal: true

require "elelem/cli"

RSpec.describe Elelem::CLI do
  describe "#run" do
    it "passes --model as a provider option and --system-prompt as role text to ask" do
      seen = nil
      allow(Elelem).to receive(:ask) { |*, **options| (seen = options) && "hi" }

      cli = described_class.new(%w[--model some.gguf --system-prompt Editor. hello])

      expect { cli.run }.to output("hi\n").to_stdout

      expect(seen[:provider_options]).to eq(model: "some.gguf")
      expect(seen[:system_prompt]).to eq("Editor.")
    end

    it "passes --model and --system-prompt to chat" do
      seen = nil
      allow(Elelem).to receive(:start) { |**options| seen = options }
      allow($stdin).to receive(:tty?).and_return(true)

      described_class.new(%w[--model some.gguf --system-prompt Editor.]).run

      expect(seen[:provider_options]).to eq(model: "some.gguf")
      expect(seen[:system_prompt]).to eq("Editor.")
    end
  end

  describe "ask" do
    before do
      Elelem.configure do |config|
        config.provider(:raising) { Class.new { def fetch(*) = raise("provider down") }.new }
      end
    end

    it "exits non-zero, with nothing on stdout, when the provider fails" do
      status = nil
      expect do
        described_class.new(%w[-p raising hello]).run
      rescue SystemExit => e
        status = e.status
      end.to output("").to_stdout.and output(/provider down/).to_stderr

      expect(status).to eq(1)
    end
  end

  describe "what to run, inferred from the arguments and stdin" do
    def with_stdin(io)
      stdin = $stdin
      $stdin = io
      yield
    ensure
      $stdin = stdin
    end

    def piped(text, &)
      Tempfile.create("stdin") do |file|
        file.write(text)
        file.rewind
        with_stdin(file, &)
      end
    end

    def asked(&)
      prompt = nil
      allow(Elelem).to receive(:ask) { |text, **| (prompt = text) && "hi" }
      expect(&).to output("hi\n").to_stdout
      prompt
    end

    it "chats with no arguments at a terminal" do
      allow(Elelem).to receive(:start)
      allow($stdin).to receive(:tty?).and_return(true)

      described_class.new([]).run

      expect(Elelem).to have_received(:start)
    end

    it "asks the arguments at a terminal" do
      allow($stdin).to receive(:tty?).and_return(true)

      expect(asked { described_class.new(%w[what is this]).run }).to eq("what is this")
    end

    it "asks the arguments with piped stdin attached" do
      expect(asked { piped("a diff") { described_class.new(%w[review this]).run } })
        .to eq("review this\n\n```\na diff\n```")
    end

    it "asks piped stdin alone" do
      expect(asked { piped("what is this") { described_class.new([]).run } }).to include("what is this")
    end

    it "leaves out the fenced block when piped stdin is empty" do
      expect(asked { piped("") { described_class.new(%w[hello]).run } }).to eq("hello")
    end

    it "prints usage and exits 1 with no arguments and no terminal" do
      status = nil
      expect do
        with_stdin(File.open(File::NULL)) { described_class.new([]).run }
      rescue SystemExit => e
        status = e.status
      end.to output(/Usage: .* \[options\] \[prompt\]/).to_stderr

      expect(status).to eq(1)
    end
  end

  it "shows progress through the configured output at a terminal" do
    seen = nil
    allow(Elelem).to receive(:ask) { |*, **options| seen = options }
    allow($stdout).to receive(:tty?).and_return(true)

    described_class.new(%w[hello]).run

    expect(seen).to include(output: nil)
  end

  it "shows progress as plain text on stderr when stdout is piped" do
    seen = nil
    allow(Elelem).to receive(:ask) do |*, **options|
      seen = options
      "hi"
    end
    allow($stdout).to receive(:tty?).and_return(false)

    expect { described_class.new(%w[hello]).run }.to output("hi\n").to_stdout
    expect(seen[:output].instance_variable_get(:@stream)).to be($stderr)
  end

  it "prints a piped reply as plain text, not a code fence" do
    expect { described_class.new([]).send(:print_reply, "hello", piped: true) }.to output("hello\n").to_stdout
  end
end
