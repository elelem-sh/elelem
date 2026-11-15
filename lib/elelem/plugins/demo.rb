# frozen_string_literal: true

module Elelem
  class DemoProvider
    def fetch(messages, tools, &)
      return yield(type: "saying", text: install_hint) unless shell?(tools)
      return yield(type: "saying", text: report(messages.last)) if messages.last[:role] == "tool"

      run(first_line_of_last_prompt(messages), id: "demo-#{messages.length}", &)
    end

    private

    def install_hint = "I have no model and no shell here. For a model: gem install elelem-llama, then elelem -p llama"
    def shell?(tools) = tools.any? { |tool| tool.dig(:function, :name) == "execute" }

    def first_line_of_last_prompt(messages)
      prompt = messages.rfind { |message| message[:role] == "user" }
      prompt[:content].to_s.lines.first.to_s.strip
    end

    def run(command, id:)
      yield(type: "thinking", text: "I'll run `#{command}`.")
      yield(type: "doing", id: id, name: "execute", arguments: { "command" => command })
    end

    def report(tool_message)
      result = JSON.parse(tool_message[:content])
      return result["error"] unless result.key?("exit_status")

      "exit #{result["exit_status"]}"
    end
  end
end

Elelem.configure do |config|
  config.provider(:demo) { Elelem::DemoProvider.new }
end
