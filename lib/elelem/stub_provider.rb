# frozen_string_literal: true

module Elelem
  # No model. Understands a tool name and its arguments, and the few plain
  # requests the docs show. Reads only the first line, so piped text never
  # becomes arguments.
  class StubProvider
    REQUESTS = [
      [/\Ashow me (\S+?)[.?!]?\z/i, "read", ->(m) { { "path" => m[1] } }],
      [%r{\Acreate (\S*[./]\S*) with (.+)\z}i, "write", ->(m) { { "path" => m[1], "content" => m[2] } }],
      [/\Awhat files are here\??\z/i, "execute", ->(_) { { "command" => "ls" } }],
      [/\Arun (?:the )?tests?\z/i, "execute",
       ->(_) { { "command" => File.executable?("bin/test") ? "bin/test" : "rake" } }],
      [/\A(?:run|execute) `?(.+?)`?\z/i, "execute", ->(m) { { "command" => m[1] } }]
    ].freeze

    HELP = <<~TEXT
      I need a model to understand that. Without one, type a tool and its
      arguments (/tools lists them), or: show me README.md, create notes.txt
      with hello, what files are here, run the tests.
      For a model: gem install elelem-llama, then elelem -p llama
    TEXT

    def fetch(messages, tools = [], &)
      return yield(type: "saying", text: summary(messages)) if messages.last[:role] == "tool"

      name, args = understand(messages.last[:content], tools)
      name ? act(name, args, messages.length, &) : yield(type: "saying", text: HELP)
    end

    private

    def act(name, args, turn)
      yield(type: "thinking", text: "I'll call #{name}.")
      yield(type: "doing", id: "stub-#{turn}", name: name, arguments: args)
    end

    def understand(content, tools)
      text = content.to_s.lines.first.to_s.strip
      request(text, tools.map { |t| t.dig(:function, :name) }) || direct(text, tools)
    end

    def request(text, names)
      REQUESTS.each do |pattern, name, build|
        match = pattern.match(text)
        return [name, build.call(match)] if match && names.include?(name)
      end
      nil
    end

    def direct(text, tools)
      name, rest = text.split(/\s+/, 2)
      tool = tools.find { |t| t.dig(:function, :name) == name }
      args = arguments(tool, rest.to_s) if tool
      [name, args] if args && file_like?(name, args)
    end

    def arguments(tool, rest)
      required = tool.dig(:function, :parameters, :required) || []
      required.zip(rest.split(/\s+/, required.size)).to_h.compact.transform_keys(&:to_s)
    end

    # A model would not write to "a" when asked to "write a commit message".
    def file_like?(name, args)
      name != "write" || args["path"].to_s.match?(%r{[./]})
    end

    def summary(messages)
      name = messages.rfind { |m| m[:tool_calls] }&.dig(:tool_calls, 0, :name)
      result = JSON.parse(messages.last[:content].to_s).except("ok")
      return "#{name} failed: #{result["error"]}." if result["error"]

      result.empty? ? "#{name} is done." : result.map { |k, v| "#{k}: #{v}" }.join("\n")
    end
  end
end
