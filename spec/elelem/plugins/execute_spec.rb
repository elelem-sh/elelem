# frozen_string_literal: true

RSpec.describe "the execute tool" do
  let(:output) { Elelem::Output.new(stream: StringIO.new) }
  let(:session) { Elelem::Config.build_session("demo", input: Elelem::NullInput.new, output: output) }

  around do |example|
    saved = ENV.delete("ELELEM_CMD_TIMEOUT")
    example.run
  ensure
    saved ? ENV.store("ELELEM_CMD_TIMEOUT", saved) : ENV.delete("ELELEM_CMD_TIMEOUT")
  end

  it "is ok when the command exits 0" do
    result = session.toolbox.run("execute", { "command" => "true" })

    expect([result.ok?, result[:exit_status]]).to eq([true, 0])
  end

  it "is not ok when the command exits non-zero, and keeps the status" do
    result = session.toolbox.run("execute", { "command" => "exit 3" })

    expect([result.ok?, result[:exit_status], result[:error]]).to eq([false, 3, "exit 3"])
  end

  it "runs a command whose output is not UTF-8" do
    result = session.toolbox.run("execute", { "command" => "printf 'a\\377b\\n'" })

    expect([result.ok?, result[:content]]).to eq([true, "a\uFFFDb\n"])
  end

  it "times out after 300 seconds by default, so a background job cannot hang the session" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with("bash", hash_including(timeout: 300))
  end

  it "takes the timeout from ELELEM_CMD_TIMEOUT" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })
    ENV["ELELEM_CMD_TIMEOUT"] = "7"

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with("bash", hash_including(timeout: 7))
  end

  it "runs without a timeout when ELELEM_CMD_TIMEOUT is 0" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })
    ENV["ELELEM_CMD_TIMEOUT"] = "0"

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with("bash", hash_including(timeout: nil))
  end
end
