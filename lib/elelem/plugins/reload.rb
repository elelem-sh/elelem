# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:reload) do |agent|
    agent.commands.register("reload", description: "Reload plugin code from disk") do
      Elelem::Config.reload(agent)
    end
  end
end
