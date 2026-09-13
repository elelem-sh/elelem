# frozen_string_literal: true

RSpec.describe Elelem::Session do
  subject(:session) { described_class.new(agent, input: input, commands: commands) }

  let(:agent) { Elelem::Agent.new(Elelem::StubProvider.new) }
  let(:input) { Elelem::NullInput.new }
  let(:commands) { Elelem::Commands.new }

  it "exposes the agent, input, and commands it was built with" do
    expect(session.agent).to eq(agent)
    expect(session.input).to eq(input)
    expect(session.commands).to eq(commands)
  end

  it "delegates provider to the agent" do
    expect(session.provider).to eq(agent.provider)
  end

  it "delegates provider= to the agent" do
    new_provider = Elelem::StubProvider.new

    session.provider = new_provider

    expect(agent.provider).to eq(new_provider)
  end

  it "delegates toolbox to the agent" do
    expect(session.toolbox).to eq(agent.toolbox)
  end

  it "delegates output to the agent" do
    expect(session.output).to eq(agent.output)
  end

  it "delegates conversation to the agent" do
    expect(session.conversation).to eq(agent.conversation)
  end

  it "delegates context to the agent" do
    expect(session.context).to eq(agent.context)
  end

  it "delegates turn to the agent" do
    allow(agent).to receive(:turn).with("hello").and_return("hi")

    expect(session.turn("hello")).to eq("hi")
  end
end
