# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:context) do |agent|
    agent.commands.register("context", description: "Show conversation context") do |args|
      messages = agent.conversation.to_a

      case args
      when nil, ""
        messages.each_with_index do |msg, i|
          role = msg[:role]
          preview = msg[:content].to_s.lines.first&.strip&.slice(0, 60) || ""
          preview += "..." if msg[:content].to_s.length > 60
          agent.output.say "  #{i + 1}. #{role}: #{preview}"
        end
      when "json"
        agent.output.say JSON.pretty_generate(messages)
      when /^\d+$/
        index = args.to_i - 1
        if index >= 0 && index < messages.length
          content = messages[index][:content].to_s
          agent.output.say(content, as: :markdown)
        else
          agent.output.say "  Invalid index: #{args}"
        end
      else
        agent.output.say "  Usage: /context [json|<number>]"
      end
    end
  end
end
