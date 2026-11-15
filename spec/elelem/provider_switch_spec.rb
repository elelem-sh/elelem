# frozen_string_literal: true

RSpec.describe Elelem::ProviderSwitch do
  let(:built) { [] }
  let(:agent) { Elelem::Agent.new(Elelem::StubProvider.new, output: Elelem::NullOutput.new) }
  let(:session) { Elelem::Session.new(agent, provider_name: "alpha", provider_options: { model: "a-1" }) }

  before do
    record = built
    Elelem.configure do |config|
      config.provider(:alpha) { |**options| record << [:alpha, options] and :alpha_provider }
      config.provider(:beta) { |**options| record << [:beta, options] and :beta_provider }
    end
  end

  it "keeps --model when switching back to the same provider" do
    described_class.new(session).call("alpha")

    expect(built).to eq([[:alpha, { model: "a-1" }]])
    expect(session.provider).to eq(:alpha_provider)
  end

  it "does not send one provider's model to another" do
    described_class.new(session).call("beta")

    expect(built).to eq([[:beta, {}]])
    expect(session.provider_name).to eq("beta")
  end

  it "uses an explicit model" do
    described_class.new(session).call("beta", "b-2")

    expect(built).to eq([[:beta, { model: "b-2" }]])
    expect(session.provider_options).to eq(model: "b-2")
  end
end

RSpec.describe Elelem::Registry do
  it "records the provider a session starts with" do
    session = Elelem::Config.build_session("stub", input: Elelem::NullInput.new, output: Elelem::NullOutput.new,
                                                   provider_options: { model: "m" })

    expect([session.provider_name, session.provider_options]).to eq(["stub", { model: "m" }])
  end
end
