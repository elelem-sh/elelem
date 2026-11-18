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

  def description
    session.toolbox.to_a.find { |tool| tool.dig(:function, :name) == "execute" }.dig(:function, :description)
  end

  it "says it runs commands in bash" do
    allow(Elelem::Builtins).to receive(:shell).and_return(:bash)

    expect(description).to eq("Run shell command (supports pipes and redirections) in bash")
  end

  it "says it runs commands in cmd.exe and what needs Git for Windows when there is no bash" do
    allow(Elelem::Builtins).to receive(:shell).and_return(:cmd)

    expect(description).to eq("Run shell command (supports pipes and redirections) in cmd.exe; " \
                              "git, glob, grep and list need Git for Windows")
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

  it "runs without a timeout by default, so a command can prompt on the terminal" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with(anything, hash_including(timeout: nil))
  end

  it "takes the timeout from ELELEM_CMD_TIMEOUT" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })
    ENV["ELELEM_CMD_TIMEOUT"] = "7"

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with(anything, hash_including(timeout: 7))
  end

  it "runs without a timeout when ELELEM_CMD_TIMEOUT is negative" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })
    ENV["ELELEM_CMD_TIMEOUT"] = "-1"

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with(anything, hash_including(timeout: nil))
  end

  it "runs without a timeout when ELELEM_CMD_TIMEOUT is 0" do
    allow(Elelem::Builtins).to receive(:sh).and_return({ exit_status: 0, content: "" })
    ENV["ELELEM_CMD_TIMEOUT"] = "0"

    session.toolbox.run("execute", { "command" => "true" })

    expect(Elelem::Builtins).to have_received(:sh).with(anything, hash_including(timeout: nil))
  end
end
