# frozen_string_literal: true

RSpec.describe Elelem::Transcript do
  describe "#to_a" do
    it "renders the default template as the system prompt when none is given" do
      transcript = described_class.new

      system_message = transcript.to_a.find { |m| m[:role] == "system" }

      expect(system_message[:content]).to include("terminal coding agent")
    end

    it "uses template: as the full ERB template, replacing the default" do
      transcript = described_class.new(template: "Custom template")

      system_message = transcript.to_a.find { |m| m[:role] == "system" }

      expect(system_message[:content]).to eq("Custom template")
    end

    it "prepends system_prompt: role text to the rendered template" do
      transcript = described_class.new(template: "Custom template", system_prompt: "Research agent.")

      system_message = transcript.to_a.find { |m| m[:role] == "system" }

      expect(system_message[:content]).to eq("Research agent.\n\nCustom template")
    end

    it "renders a model-authored system_prompt literally, never as ERB" do
      transcript = described_class.new(template: "Custom template", system_prompt: "<%= 1 + 1 %>")

      system_message = transcript.to_a.find { |m| m[:role] == "system" }

      expect(system_message[:content]).to eq("<%= 1 + 1 %>\n\nCustom template")
    end
  end
end
