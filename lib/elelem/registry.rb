# frozen_string_literal: true

module Elelem
  class Registry
    def initialize(plugins: Plugins.new)
      @registration = Registration.new
      @plugins = plugins
    end

    def configure
      yield @registration
      self
    end

    def build_provider(name, **)
      @plugins.load!
      @registration.providers.fetch(name.to_s) { require_gem(name) }.call(**)
    end

    def apply(session)
      @plugins.load!
      @registration.setups.each_value { |block| block.call(session) }
    end

    def reload(session)
      @registration.clear_setups_from!(@plugins.dirs)
      session.toolbox.clear!
      session.commands.clear!
      @plugins.load!(force: true)
      apply(session)
    end

    def names
      @registration.providers.keys
    end

    def build_session(provider, toolbox: Toolbox.new, input: nil, output: nil, provider_options: {},
                      template: nil, system_prompt: nil)
      commands = Commands.new
      agent = Agent.new(build_provider(provider, **provider_options), toolbox: toolbox, output: output || build_output,
                                                                      template: template, system_prompt: system_prompt)
      session = Session.new(agent, input: input || build_input(commands: commands), commands: commands)
      apply(session)
      session
    end

    private

    def build_input(**) = build(:input, Input, **)
    def build_output = build(:output, Output)

    # A plugin's factory, else core's class.
    def build(kind, klass, **)
      @plugins.load!
      (@registration.factories[kind] || klass.method(:new)).call(**)
    end

    def require_gem(name)
      require "elelem/#{name}"
      @registration.providers.fetch(name.to_s) { raise "elelem-#{name} did not register provider #{name.inspect}" }
    rescue LoadError => e
      raise unless e.path == "elelem/#{name}"

      raise "unknown provider: #{name.inspect}. Available: #{names.join(", ")}. Run: gem install elelem-#{name}"
    end
  end
end
