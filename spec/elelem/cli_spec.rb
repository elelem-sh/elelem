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

  it "prints a piped reply as plain text, not a code fence" do
    expect { described_class.new([]).send(:print_reply, "hello", piped: true) }.to output("hello\n").to_stdout
  end
end
