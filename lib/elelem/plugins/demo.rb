# frozen_string_literal: true

module Elelem
  class DemoProvider
    def fetch(messages, tools, &)
      return yield(type: "saying", text: install_hint) unless shell?(tools)
      return yield(type: "saying", text: report(messages.last)) if messages.last[:role] == "tool"

      use(*tool_for(first_line_of_last_prompt(messages)), id: "demo-#{messages.length}", &)
    end

    private

    def install_hint = "I have no model and no shell here. For a model: gem install elelem-llama, then elelem -p llama"
    def shell?(tools) = tools.any? { |tool| tool.dig(:function, :name) == "execute" }

    def first_line_of_last_prompt(messages)
      prompt = messages.rfind { |message| message[:role] == "user" }
      prompt[:content].to_s.lines.first.to_s.strip
    end

    def tool_for(line)
      line.start_with?("@") ? ["read", { "path" => line.delete_prefix("@") }] : ["execute", { "command" => line }]
    end

    def use(name, arguments, id:)
      yield(type: "thinking", text: "I'll #{name} `#{arguments.values.first}`.")
      yield(type: "doing", id: id, name: name, arguments: arguments)
    end

    def report(tool_message)
      result = JSON.parse(tool_message[:content])
      return result["error"] if result["error"]

      result.key?("exit_status") ? "exit #{result["exit_status"]}" : "read #{result["path"]}"
    end
  end
end

Elelem.configure do |config|
  config.provider(:demo) { Elelem::DemoProvider.new }
end
