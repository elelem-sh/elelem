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
      session = Session.new(agent, input: input || build_input(commands: commands), commands: commands,
                                   provider_name: provider, provider_options: provider_options)
      apply(session)
      session
    end

    private

    def build_input(**)
      @plugins.load!
      (@registration.factories[:input] || ->(**o) { Input.new(**o) }).call(**)
    end

    def build_output(**)
      @plugins.load!
      (@registration.factories[:output] || ->(**o) { Output.new(**o) }).call(**)
    end

    def require_gem(name)
      require "elelem/#{name}"
      @registration.providers.fetch(name.to_s) { unregistered_provider(name) }
    rescue LoadError
      raise "unknown provider: #{name.inspect}. Available: #{names.join(", ")}. Run: gem install elelem-#{name}"
    end

    def unregistered_provider(name)
      raise "elelem-#{name} did not register a provider named #{name.inspect}"
    end
  end
end
