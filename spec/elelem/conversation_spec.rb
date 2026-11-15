# frozen_string_literal: true

RSpec.describe Elelem::Conversation do
  subject { described_class.new }

  describe "#add" do
    it "appends messages" do
      subject.add(role: "user", content: "hello")
      subject.add(role: "assistant", content: "hi")
      expect(subject.to_a.drop(1).map { |m| m[:content] }).to eq(%w[hello hi])
    end

    it "validates role" do
      expect { subject.add(role: "invalid", content: "test") }.to raise_error(ArgumentError, /invalid role/)
    end

    it "accepts user role" do
      expect { subject.add(role: "user", content: "test") }.not_to raise_error
    end

    it "accepts assistant role" do
      expect { subject.add(role: "assistant", content: "test") }.not_to raise_error
    end

    it "accepts tool role" do
      expect { subject.add(role: "tool", content: "test") }.not_to raise_error
    end
  end

  describe "#last" do
    it "returns the last message" do
      subject.add(role: "user", content: "hello")
      subject.add(role: "assistant", content: "hi")
      expect(subject.last[:content]).to eq("hi")
    end
  end

  describe "#clear!" do
    it "removes all messages" do
      subject.add(role: "user", content: "hello")
      subject.clear!
      expect(subject.to_a.map { |m| m[:role] }).to eq(["system"])
    end
  end

  describe "#to_a" do
    it "puts the system prompt first, then the messages, then any extra" do
      subject.add(role: "user", content: "hello")
      extra = { role: "tool", content: "{}" }

      expect(subject.to_a([extra]).map { |m| m[:role] }).to eq(%w[system user tool])
    end

    it "renders the default template as the system prompt when none is given" do
      expect(subject.to_a.first[:content]).to include("terminal coding agent")
    end

    it "uses template: as the full ERB template, replacing the default" do
      conversation = described_class.new(template: "Custom template")

      expect(conversation.to_a.first).to eq(role: "system", content: "Custom template")
    end

    it "prepends system_prompt: role text to the rendered template" do
      conversation = described_class.new(template: "Custom template", system_prompt: "Research agent.")

      expect(conversation.to_a.first[:content]).to eq("Research agent.\n\nCustom template")
    end

    it "renders a model-authored system_prompt literally, never as ERB" do
      conversation = described_class.new(template: "Custom template", system_prompt: "<%= 1 + 1 %>")

      expect(conversation.to_a.first[:content]).to eq("<%= 1 + 1 %>\n\nCustom template")
    end
  end
end
