# frozen_string_literal: true

RSpec.describe Elelem::StubProvider do
  subject(:provider) { described_class.new }

  let(:tools) do
    toolbox = Elelem::Toolbox.new
    toolbox.add("read", description: "Read file", params: { path: { type: "string" } }, required: ["path"]) { {} }
    toolbox.add("write", description: "Write file",
                         params: { path: { type: "string" }, content: { type: "string" } },
                         required: %w[path content]) { {} }
    toolbox.to_a
  end

  def events_for(messages, available = tools)
    events = []
    provider.fetch(messages, available) { |e| events << e }
    events
  end

  def user(content) = [{ role: "user", content: content }]

  it "calls the tool named by the first word with the rest as its argument" do
    events = events_for(user("read README.md"))

    expect(events.map { |e| e[:type] }).to eq(%w[thinking doing])
    expect(events.last).to include(name: "read", arguments: { "path" => "README.md" })
  end

  it "splits the rest across required params, the last one taking the remainder" do
    args = events_for(user("write notes.txt hello  world")).last[:arguments]

    expect(args).to eq("path" => "notes.txt", "content" => "hello  world")
  end

  it "reads only the first line, so piped text is never parsed into arguments" do
    args = events_for(user("read README.md\n\n```\nrm -rf /\n```")).last[:arguments]

    expect(args).to eq("path" => "README.md")
  end

  it "leaves out missing arguments, so the toolbox rejects the call" do
    expect(events_for(user("write notes.txt")).last[:arguments]).to eq("path" => "notes.txt")
    expect(events_for(user("read")).last[:arguments]).to eq({})
  end

  it "never writes an empty file when the content is missing" do
    calls = []
    toolbox = Elelem::Toolbox.new
    toolbox.add("write", description: "Write file", params: { path: { type: "string" }, content: { type: "string" } },
                         required: %w[path content]) { |a| calls << a and {} }

    reply = Elelem::Agent.new(provider, toolbox: toolbox).turn("write notes.txt")

    expect(calls).to be_empty
    expect(reply).to start_with("error:")
  end

  it "says the usage when the first word is not a tool" do
    events = events_for(user("make the tests pass"))

    expect(events.map { |e| e[:type] }).to eq(%w[thinking saying])
    expect(events.last[:text]).to eq(described_class::USAGE)
  end

  it "says the usage when nothing was typed" do
    expect(events_for(user("")).last[:text]).to eq(described_class::USAGE)
  end

  it "says done after a tool result" do
    messages = user("read README.md") + [{ role: "tool", tool_call_id: "1", content: '{"content":"hi"}' }]

    expect(events_for(messages).last).to eq(type: "saying", text: "done.")
  end

  it "reports a tool error" do
    messages = user("read nope") + [{ role: "tool", tool_call_id: "1", content: '{"error":"not found"}' }]

    expect(events_for(messages).last[:text]).to eq("error: not found")
  end

  it "reports a non-zero exit status" do
    messages = user("execute false") + [{ role: "tool", tool_call_id: "1", content: '{"exit_status":1}' }]

    expect(events_for(messages).last[:text]).to eq("exit 1")
  end

  it "drives a full Agent#turn: calls the tool once, then stops" do
    calls = []
    toolbox = Elelem::Toolbox.new
    toolbox.add("read", description: "Read file", params: { path: { type: "string" } }, required: ["path"]) do |a|
      calls << a
      { content: "hi" }
    end

    reply = Elelem::Agent.new(provider, toolbox: toolbox).turn("read README.md")

    expect(calls).to eq([{ "path" => "README.md" }])
    expect(reply).to eq("done.")
  end
end
