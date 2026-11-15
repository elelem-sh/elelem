# frozen_string_literal: true

RSpec.describe "the execute tool" do
  let(:session) { Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: Elelem::NullOutput.new) }

  it "is ok when the command exits 0" do
    result = session.toolbox.run("execute", { "command" => "true" })

    expect([result.ok?, result[:exit_status]]).to eq([true, 0])
  end

  it "is not ok when the command exits non-zero, and keeps the status" do
    result = session.toolbox.run("execute", { "command" => "exit 3" })

    expect([result.ok?, result[:exit_status]]).to eq([false, 3])
  end
end
