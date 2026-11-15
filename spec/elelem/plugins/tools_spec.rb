# frozen_string_literal: true

RSpec.describe "the /tools command" do
  let(:said) { [] }
  let(:output) do
    said = self.said
    Elelem::NullOutput.new.tap { |o| o.define_singleton_method(:say) { |text, **| said << text } }
  end
  let(:session) { Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: output) }

  before do
    session.toolbox.add("greet", description: "Greets someone.\nMore detail.",
                                 params: { name: { type: "string", description: "who to greet" } },
                                 required: ["name"], aliases: ["hi"]) { {} }
    session.toolbox.add("plain", description: "Plain.") { {} }
  end

  it "lists each tool with the first line of its description" do
    session.commands.run("tools")

    expect(said.last).to start_with("| Tool | Description |\n|------|-------------|\n")
    expect(said.last).to include("| greet | Greets someone. |", "| plain | Plain. |")
  end

  it "describes one tool: name, description, params and aliases" do
    session.commands.run("tools", "greet")

    expect(said.last).to include("## greet", "Greets someone.\nMore detail.",
                                 "- `name` (string, required) - who to greet", "*aliases: hi*")
  end

  it "omits the aliases line when there are none" do
    session.commands.run("tools", "plain")

    expect(said.last).not_to include("aliases:")
  end

  it "says when a tool is unknown" do
    session.commands.run("tools", "nope")

    expect(said.last).to eq("Unknown tool: nope")
  end
end
