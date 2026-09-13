# frozen_string_literal: true

RSpec.describe Elelem::Repl do
  def input_returning(*lines)
    queue = lines.dup
    Class.new do
      define_method(:ask) { |_prompt| queue.shift }
    end.new
  end

  def capturing_output
    said = []
    output = Elelem::NullOutput.new
    output.define_singleton_method(:say) { |text, **| said << text }
    [output, said]
  end

  def session_with(input:, output: Elelem::NullOutput.new, commands: Elelem::Commands.new)
    agent = Elelem::Agent.new(Elelem::TestProvider.new, output: output)
    Elelem::Session.new(agent, input: input, commands: commands)
  end

  it "says the version banner and reads until input returns nil" do
    output, said = capturing_output
    session = session_with(input: input_returning(nil), output: output)

    described_class.new(session).run

    expect(said.first).to eq("elelem v#{Elelem::VERSION}")
  end

  it "skips empty lines without turning or dispatching a command" do
    output, said = capturing_output
    session = session_with(input: input_returning("", nil), output: output)

    described_class.new(session).run

    expect(said).to eq(["elelem v#{Elelem::VERSION}"])
  end

  it "dispatches a plain line as a turn" do
    session = session_with(input: input_returning("hello", nil))
    turned = nil
    session.define_singleton_method(:turn) { |prompt| turned = prompt }

    described_class.new(session).run

    expect(turned).to eq("hello")
  end

  it "dispatches a slash-prefixed line as a command" do
    commands = Elelem::Commands.new
    ran = nil
    commands.register("greet") { |args| ran = args }
    session = session_with(input: input_returning("/greet world", nil), commands: commands)

    described_class.new(session).run

    expect(ran).to eq("world")
  end

  it "shows available commands when the slash command is unknown" do
    output, said = capturing_output
    session = session_with(input: input_returning("/bogus", nil), output: output, commands: Elelem::Commands.new)

    described_class.new(session).run

    expect(said.last).to eq("")
  end

  it "logs and reports the error when a command raises" do
    commands = Elelem::Commands.new
    commands.register("boom") { raise "kaboom" }
    output, said = capturing_output
    session = session_with(input: input_returning("/boom", nil), output: output, commands: commands)

    described_class.new(session).run

    expect(said.last).to eq("kaboom")
  end
end
