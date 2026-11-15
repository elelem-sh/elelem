# frozen_string_literal: true

RSpec.describe "the /provider command" do
  let(:session) { Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: Elelem::NullOutput.new) }

  it "passes model: only when one is typed" do
    allow(Elelem::Config).to receive(:build_provider).and_call_original

    session.commands.run("provider", "stub")
    session.commands.run("provider", "stub some.gguf")

    expect(Elelem::Config).to have_received(:build_provider).with("stub")
    expect(Elelem::Config).to have_received(:build_provider).with("stub", model: "some.gguf")
  end
end
