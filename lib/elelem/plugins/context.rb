# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:context) do |agent|
    preview = lambda do |message|
      content = message[:content].to_s
      "#{content.lines.first&.strip&.slice(0, 60)}#{"..." if content.length > 60}"
    end

    agent.commands.register("context", description: "Show conversation context") do |args|
      messages = agent.conversation.to_a

      case args
      when nil, ""
        messages.each.with_index(1) do |message, number|
          agent.output.say "  #{number}. #{message[:role]}: #{preview.call(message)}"
        end
      when "json"
        agent.output.say JSON.pretty_generate(messages)
      when /\A\d+\z/
        if args.to_i.between?(1, messages.length)
          agent.output.say(messages[args.to_i - 1][:content].to_s, as: :markdown)
        else
          agent.output.say "  Invalid index: #{args}"
        end
      else
        agent.output.say "  Usage: /context [json|<number>]"
      end
    end
  end
end
