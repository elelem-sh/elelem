# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:provider) do |session|
    session.commands.register("provider", description: "Switch provider: /provider NAME [MODEL]", completions: lambda {
      Elelem::Config.names
    }) do |args|
      name, model = args.to_s.split
      next session.output.say("  -> available: #{Elelem::Config.names.join(", ")}") if name.nil?

      # --model carries over only to the provider it was given for.
      options = if model then { model: }
                elsif name == session.provider_name then session.provider_options
                else {}
                end
      session.provider = Elelem::Config.build_provider(name, **options)
      session.provider_name = name
      session.provider_options = options
      session.output.say "  -> switched to #{name}"
    end
  end
end
