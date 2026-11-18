# frozen_string_literal: true

module Elelem
  class Registry
    def initialize(plugins: Plugins.new)
      @plugins = plugins
      @providers = {}
      @setups = {}
      @factories = { input: Input.method(:new), output: Builtins::Terminal.method(:new) }
    end

    def configure
      yield self
      self
    end

    def provider(name, &factory) = @providers[name.to_s] = factory
    def setup(name, &block) = @setups[name.to_s] = block
    def input(&factory) = @factories[:input] = factory
    def output(&factory) = @factories[:output] = factory

    def build_provider(name, **)
      @plugins.load!
      @providers.fetch(name.to_s) { require_gem(name) }.call(**)
    end

    def apply(session)
      @plugins.load!
      @setups.each_value { |block| block.call(session) }
    end

    def reload(session)
      session.toolbox.clear!
      session.commands.clear!
      @plugins.load!(force: true)
      apply(session)
    end

    def names
      @providers.keys
    end

    def build_session(provider, toolbox: Toolbox.new, input: nil, output: nil, provider_options: {},
                      template: nil, system_prompt: nil)
      commands = Commands.new
      agent = build_agent(provider, provider_options, toolbox:, template:, system_prompt:, output:)
      session = Session.new(agent, input: input || @factories[:input].call(commands: commands), commands: commands)
      apply(session)
      session
    end

    private

    def build_agent(provider, provider_options, output:, **)
      Agent.new(build_provider(provider, **provider_options), output: output || @factories[:output].call, **)
    end

    def require_gem(name)
      require "elelem/#{name}"
      @providers.fetch(name.to_s) { raise "elelem-#{name} did not register provider #{name.inspect}" }
    rescue LoadError => e
      raise unless e.path == "elelem/#{name}"

      raise "unknown provider: #{name.inspect}. Available: #{names.join(", ")}. Run: gem install elelem-#{name}"
    end
  end
end
