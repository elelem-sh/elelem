# frozen_string_literal: true

require "elelem/cli"

RSpec.describe Elelem::CLI do
  describe "#run" do
    it "passes --model as a provider option and --system-prompt as role text to ask" do
      seen = nil
      allow(Elelem).to receive(:ask) { |*, **options| seen = options }

      described_class.new(%w[ask --model some.gguf --system-prompt Editor. hello]).run

      expect(seen[:provider_options]).to eq(model: "some.gguf")
      expect(seen[:system_prompt]).to eq("Editor.")
    end

    it "passes --model and --system-prompt to chat" do
      seen = nil
      allow(Elelem).to receive(:start) { |**options| seen = options }

      described_class.new(%w[chat --model some.gguf --system-prompt Editor.]).run

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
        described_class.new(%w[ask -p raising hello]).run
      rescue SystemExit => e
        status = e.status
      end.to output("").to_stdout.and output(/provider down/).to_stderr

      expect(status).to eq(1)
    end

    it "appends stdin redirected from a file to the prompt" do
      Tempfile.create("stdin") do |file|
        file.write("from a file")
        file.rewind
        stdin = $stdin
        $stdin = file
        expect(described_class.new(%w[summarize]).send(:prompt_for_ask)).to include("from a file")
      ensure
        $stdin = stdin
      end
    end

    it "names the elelem command in its usage error" do
      expect { described_class.new(%w[ask]).run }.to raise_error(SystemExit)
        .and output(/Usage: elelem ask <prompt>/).to_stderr
    end
  end

  it "shows progress through the configured output at a terminal" do
    seen = nil
    allow(Elelem).to receive(:ask) { |*, **options| seen = options }
    allow($stdout).to receive(:tty?).and_return(true)

    described_class.new(%w[ask hello]).run

    expect(seen).to include(output: nil)
  end

  it "shows progress as plain text on stderr when stdout is piped" do
    seen = nil
    allow(Elelem).to receive(:ask) do |*, **options|
      seen = options
      "hi"
    end
    allow($stdout).to receive(:tty?).and_return(false)

    expect { described_class.new(%w[ask hello]).run }.to output("hi\n").to_stdout
    expect(seen[:output].instance_variable_get(:@stream)).to be($stderr)
  end

  it "prints a piped reply as plain text, not a code fence" do
    expect { described_class.new([]).send(:print_reply, "hello", piped: true) }.to output("hello\n").to_stdout
  end
end
