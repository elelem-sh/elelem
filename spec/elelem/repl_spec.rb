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
    agent = Elelem::Agent.new(Elelem::Config.build_provider("demo"), output: output)
    Elelem::Session.new(agent, input: input, commands: commands)
  end

  it "remembers prompt lines, not empty ones" do
    input = input_returning("hello", "", nil)
    remembered = []
    input.define_singleton_method(:remember) { |line| remembered << line }
    described_class.new(session_with(input: input)).run

    expect(remembered).to eq(["hello"])
  end

  it "runs with an input that cannot remember" do
    expect { described_class.new(session_with(input: input_returning("hello", nil))).run }.not_to raise_error
  end

  it "says the version banner and reads until input returns nil" do
    output, said = capturing_output
    session = session_with(input: input_returning(nil), output: output)

    described_class.new(session).run

    expect(said.first).to eq("elelem v#{Elelem::VERSION} · /help")
  end

  it "names the provider and the model it was started with in the banner" do
    output, said = capturing_output
    session = session_with(input: input_returning(nil), output: output)

    described_class.new(session, provider: "anthropic", model: "claude").run

    expect(said.first).to eq("elelem v#{Elelem::VERSION} · anthropic (claude) · /help")
  end

  it "names the model the provider reports over the one it was started with" do
    output, said = capturing_output
    session = session_with(input: input_returning(nil), output: output)
    session.provider.define_singleton_method(:model) { "qwen.gguf" }

    described_class.new(session, provider: "llama").run

    expect(said.first).to eq("elelem v#{Elelem::VERSION} · llama (qwen.gguf) · /help")
  end

  it "skips empty lines without turning or dispatching a command" do
    output, said = capturing_output
    session = session_with(input: input_returning("", nil), output: output)

    described_class.new(session).run

    expect(said).to eq(["elelem v#{Elelem::VERSION} · /help"])
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

  it "sends a line starting with a path to the model, not to the commands" do
    session = session_with(input: input_returning("/etc/hosts has a bad entry", nil))
    turned = nil
    session.define_singleton_method(:turn) { |prompt| turned = prompt }

    described_class.new(session).run

    expect(turned).to eq("/etc/hosts has a bad entry")
  end

  it "says a failed turn once as an error and keeps reading" do
    output, said = capturing_output
    errors = []
    output.define_singleton_method(:say) { |text, as: nil| (as == :error ? errors : said) << text }
    session = session_with(input: input_returning("first", "second", nil), output: output)
    turned = []
    session.define_singleton_method(:turn) { |prompt| turned << prompt and raise "provider down" }

    described_class.new(session).run

    expect([errors, turned]).to eq([["provider down", "provider down"], %w[first second]])
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
