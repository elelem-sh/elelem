# frozen_string_literal: true

RSpec.describe Elelem::Builtins::ToolMarkdown do
  subject(:tool) do
    Elelem::Tool.new("greet",
                     description: "Greets someone.\nMore detail.",
                     schema: Elelem::Schema.new(
                       params: { name: { type: "string", description: "who to greet" } },
                       required: ["name"]
                     ),
                     aliases: ["hi"]) { |args| { greeting: "hi #{args["name"]}" } }
  end

  describe ".summary" do
    it "renders a single table row with the first description line" do
      expect(described_class.summary(tool)).to eq("| greet | Greets someone. |")
    end
  end

  describe ".to_markdown" do
    it "renders name, description, params, and aliases" do
      markdown = described_class.to_markdown(tool)

      expect(markdown).to include("## greet")
      expect(markdown).to include("Greets someone.\nMore detail.")
      expect(markdown).to include("- `name` (string, required) - who to greet")
      expect(markdown).to include("*aliases: hi*")
    end

    it "omits the aliases line when there are none" do
      plain_tool = Elelem::Tool.new("greet", description: "Greets someone.") {}

      expect(described_class.to_markdown(plain_tool)).not_to include("aliases:")
    end
  end
end
