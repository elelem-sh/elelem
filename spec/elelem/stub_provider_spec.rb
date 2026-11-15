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
    expect(reply).to start_with("write failed:")
  end

  describe "plain requests" do
    let(:tools) do
      toolbox = Elelem::Toolbox.new
      toolbox.add("read", description: "Read file", params: { path: { type: "string" } }, required: ["path"]) { {} }
      toolbox.add("write", description: "Write file",
                           params: { path: { type: "string" }, content: { type: "string" } },
                           required: %w[path content]) { {} }
      toolbox.add("execute", description: "Run", params: { command: { type: "string" } }, required: ["command"]) { {} }
      toolbox.to_a
    end

    {
      "show me README.md" => ["read", { "path" => "README.md" }],
      "create notes.txt with hello world" => ["write", { "path" => "notes.txt", "content" => "hello world" }],
      "execute ls" => ["execute", { "command" => "ls" }],
      "what files are here?" => ["execute", { "command" => "ls" }],
      "run `git status`" => ["execute", { "command" => "git status" }],
      "write notes.txt hi" => ["write", { "path" => "notes.txt", "content" => "hi" }]
    }.each do |request, (name, args)|
      it "understands #{request.inspect}" do
        events = events_for(user(request))

        expect(events.map { |e| e[:type] }).to eq(%w[thinking doing])
        expect(events.last).to include(name: name, arguments: args)
      end
    end

    it "runs bin/test for the tests when it exists, else rake" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          expect(events_for(user("run the tests")).last[:arguments]).to eq("command" => "rake")
          FileUtils.mkdir_p("bin")
          File.write("bin/test", "")
          File.chmod(0o755, "bin/test")
          expect(events_for(user("run the tests")).last[:arguments]).to eq("command" => "bin/test")
        end
      end
    end

    it "never writes to a word that is not a file name" do
      expect(events_for(user("write a commit message")).last[:text]).to eq(described_class::HELP)
      expect(events_for(user("create docs with hugo")).last[:text]).to eq(described_class::HELP)
    end

    it "runs tests without 'the' and reads a path followed by a period" do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) { expect(events_for(user("run tests")).last[:arguments]).to eq("command" => "rake") }
      end
      expect(events_for(user("show me README.md.")).last[:arguments]).to eq("path" => "README.md")
    end

    it "never puts piped text into a command" do
      args = events_for(user("run ls\n\n```\nrm -rf /\n```")).last[:arguments]

      expect(args).to eq("command" => "ls")
    end
  end

  it "only uses tools the session offers" do
    expect(events_for(user("what files are here?")).last[:text]).to eq(described_class::HELP)
  end

  it "says honestly what it can do when it does not understand" do
    events = events_for(user("make the tests pass"))

    expect(events).to eq([{ type: "saying", text: described_class::HELP }])
  end

  it "says what it can do when nothing was typed" do
    expect(events_for(user("")).last[:text]).to eq(described_class::HELP)
  end

  def after(name, args, result)
    user("x") + [{ role: "assistant", content: "", tool_calls: [{ id: "1", name: name, arguments: args }] },
                 { role: "tool", tool_call_id: "1", content: result.to_json }]
  end

  it "summarises a tool result as its fields" do
    expect(events_for(after("write", { "path" => "a.txt" }, { bytes: 5, ok: true })).last[:text]).to eq("bytes: 5")
    expect(events_for(after("now", {}, { time: "noon", zone: "UTC" })).last[:text]).to eq("time: noon\nzone: UTC")
    expect(events_for(after("noop", {}, { ok: true })).last[:text]).to eq("noop is done.")
  end

  it "reports a tool error" do
    text = events_for(after("read", { "path" => "nope" }, { error: "not found" })).last[:text]

    expect(text).to eq("read failed: not found.")
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
    expect(reply).to eq("content: hi")
  end
end
