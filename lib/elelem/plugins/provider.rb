# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:provider) do |agent|
    agent.commands.register("provider", description: "Switch provider: /provider NAME [MODEL]", completions: lambda {
      Elelem::Config.names
    }) do |args|
      name, model = args.to_s.split
      next agent.output.say("  -> available: #{Elelem::Config.names.join(", ")}") if name.nil?

      agent.provider = Elelem::Config.build_provider(name, **{ model: }.compact)
      agent.output.say "  -> switched to #{name}"
    end
  end
end
