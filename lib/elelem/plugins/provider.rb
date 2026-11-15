# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:provider) do |session|
    session.commands.register("provider", description: "Switch provider: /provider NAME [MODEL]", completions: lambda {
      Elelem::Config.names
    }) do |args|
      name, model = args.to_s.split
      if name.nil?
        session.output.say "  -> available: #{Elelem::Config.names.join(", ")}"
      else
        Elelem::ProviderSwitch.new(session).call(name, model)
        session.output.say "  -> switched to #{name}"
      end
    end
  end
end
