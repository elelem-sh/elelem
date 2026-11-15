# frozen_string_literal: true

RSpec.describe Elelem::Agent do
  describe "#turn" do
    it "resolves an alias to its canonical name before rendering" do
      toolbox = Elelem::Toolbox.new
      toolbox.add("read", description: "Read", aliases: ["open"]) { |_a| { ok: true } }

      rendered = nil
      output = Elelem::NullOutput.new
      output.define_singleton_method(:doing) { |name, _args, **| rendered = name }

      agent = described_class.new(FakeProvider.calling("open", {}), toolbox: toolbox, output: output)
      agent.turn("go")

      expect(rendered).to eq("read")
    end

    it "does not raise when dispatching a tool call against the real NullOutput default" do
      toolbox = Elelem::Toolbox.new
      toolbox.add("noop", description: "noop") { |_a| {} }

      agent = described_class.new(FakeProvider.calling("noop", {}), toolbox: toolbox)

      expect { agent.turn("go") }.not_to raise_error
    end

    it "lets a provider error leave the turn instead of replying with it" do
      broken_provider = Class.new do
        def fetch(*) = require("nope/not/real")
      end.new

      agent = described_class.new(broken_provider, toolbox: Elelem::Toolbox.new)

      expect { agent.turn("go") }.to raise_error(LoadError)
      expect(agent.conversation.last[:role]).to eq("user")
    end
  end
end
