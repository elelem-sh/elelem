# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:provider) do |agent|
    agent.commands.register("provider", description: "Switch provider", completions: lambda {
      Elelem::Config.names
    }) do |name|
      if name.nil? || name.empty?
        agent.output.say "  -> available: #{Elelem::Config.names.join(", ")}"
      else
        agent.provider = Elelem::Config.build_provider(name)
        agent.output.say "  -> switched to #{name}"
      end
    end
  end
end
