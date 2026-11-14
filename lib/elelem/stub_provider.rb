# frozen_string_literal: true

module Elelem
  # No model. Does what you type: the first word names a tool, the rest are its arguments.
  class StubProvider
    USAGE = <<~TEXT
      No model here. Type a tool and its arguments: read README.md · write notes.txt hi · execute ls
      For a real model: gem install elelem-llama, then elelem -p llama
      Docs: https://elelem.sh
    TEXT

    def fetch(messages, tools = [], &)
      last = messages.last
      return report(last[:content], &) if last[:role] == "tool"

      name, rest = first_line(last[:content]).split(/\s+/, 2)
      tool = tools.find { |t| t.dig(:function, :name) == name }
      tool ? call(tool, name, rest.to_s, messages.length, &) : unknown(name, &)
    end

    private

    def first_line(content)
      content.to_s.lines.first.to_s.strip
    end

    def unknown(name, &)
      say(name ? "#{name} is not a tool." : "nothing typed.", USAGE, &)
    end

    def call(tool, name, rest, turn, &block)
      args = arguments(tool, rest)
      block.call(type: "thinking", text: "#{name}: #{args.map { |k, v| "#{k} = #{v}" }.join(", ")}")
      block.call(type: "doing", id: "stub-#{turn}", name: name, arguments: args)
    end

    def arguments(tool, rest)
      required = tool.dig(:function, :parameters, :required) || []
      values = rest.split(/\s+/, required.size)
      required.zip(values).to_h.compact.transform_keys(&:to_s)
    end

    def report(content, &)
      result = parse(content)
      return say("the tool failed.", "error: #{result["error"]}", &) if result["error"]
      return say("the command failed.", "exit #{result["exit_status"]}", &) if result["exit_status"].to_i.nonzero?

      say("the tool ran.", "done.", &)
    end

    def parse(content)
      result = JSON.parse(content.to_s)
      result.is_a?(Hash) ? result : {}
    rescue JSON::ParserError
      {}
    end

    def say(thought, text, &block)
      block.call(type: "thinking", text: thought)
      block.call(type: "saying", text: text)
    end
  end
end
