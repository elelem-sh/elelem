# frozen_string_literal: true

RSpec.describe "the demo provider" do
  subject(:provider) { Elelem::Config.build_provider("demo") }

  let(:execute) { [{ type: "function", function: { name: "execute" } }] }

  def events_for(messages, tools = execute)
    [].tap { |events| provider.fetch(messages, tools) { |event| events << event } }
  end

  def prompt(content) = [{ role: "system", content: "You are elelem." }, { role: "user", content: content }]

  def after(result)
    prompt("ls") + [{ role: "assistant", content: "", tool_calls: [{ id: "1", name: "execute", arguments: {} }] },
                    { role: "tool", tool_call_id: "1", content: result.to_json }]
  end

  it "runs what you type as a shell command" do
    events = events_for(prompt("ls -la"))

    expect(events.first).to eq(type: "thinking", text: "I'll run `ls -la`.")
    expect(events.last).to include(type: "doing", name: "execute", arguments: { "command" => "ls -la" })
  end

  it "runs only x for `cat file | elelem ask x`" do
    events = events_for(prompt("x\n\n```\nfile contents\n```"))

    expect(events.last[:arguments]).to eq("command" => "x")
  end

  it "says the exit status and the output of the command" do
    events = events_for(after(exit_status: 3, content: "a.txt\n", ok: false, error: "exit 3"))

    expect(events).to eq([{ type: "saying", text: "exit 3\n\na.txt" }])
  end

  it "says the error when the command never ran" do
    events = events_for(after(ok: false, error: "unknown tool"))

    expect(events).to eq([{ type: "saying", text: "unknown tool" }])
  end

  it "says how to install a model when the session has no execute tool" do
    events = events_for(prompt("ls"), [])

    expect(events.map { |event| event[:type] }).to eq(["saying"])
    expect(events.last[:text]).to include("gem install elelem-llama, then elelem -p llama")
  end

  it "is still registered as stub, for elelem-server 0.13.x" do
    expect(Elelem::Config.build_provider("stub")).to be_a(Elelem::DemoProvider)
  end

  it "drives a full turn: runs the command once, then replies" do
    session = Elelem::Config.build_session("demo", input: Elelem::NullInput.new, output: Elelem::NullOutput.new)

    expect(session.turn("echo hi\n\n```\nexit 1\n```")).to eq("exit 0\n\nhi")
  end

  it "reloads without warnings" do
    plugin = File.expand_path("../../../lib/elelem/plugins/demo.rb", __dir__)

    expect { load(plugin) }.not_to output.to_stderr
  end
end
