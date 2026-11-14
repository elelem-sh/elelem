# frozen_string_literal: true

module Elelem
  # No model. Understands a few plain requests, or a tool name and its arguments.
  # Reads only the first line, so piped text never becomes arguments.
  class StubProvider
    INTENTS = [
      [/\A(?:show(?: me)?|cat|open|read|print|what['\u2019]?s in|what is in|look at)\s+(?:the file\s+)?(\S+?)[.?!]?\z/i,
       "read", ->(m) { { "path" => m[1] } }],
      [%r{\A(?:create|make|write)\s+(?:a file\s+)?(?:called\s+|named\s+)?(\S*[./]\S*)\s+(?:with|containing)\s+(.+)\z}i,
       "write", ->(m) { { "path" => m[1], "content" => m[2] } }],
      [/\A(?:run|execute)\s+(?:the\s+)?tests?[.?!]?\z/i,
       "execute", ->(_) { { "command" => File.executable?("bin/test") ? "bin/test" : "rake" } }],
      [/\A(?:what files are (?:here|there)|list (?:the )?files|ls)\??\z/i,
       "execute", ->(_) { { "command" => "ls" } }],
      [/\A(?:run|execute)\s+`?(.+?)`?\z/i, "execute", ->(m) { { "command" => m[1] } }]
    ].freeze

    THOUGHTS = {
      "read" => ->(a) { "The user wants to see #{a["path"]}. I'll read it." },
      "write" => ->(a) { "I'll write #{a["path"]}." },
      "execute" => ->(a) { "I'll run `#{a["command"]}`." }
    }.freeze

    SUMMARIES = {
      "read" => ->(a, r) { "#{a["path"]} has #{StubProvider.lines(r["content"])}." },
      "write" => ->(a, r) { "Wrote #{r["bytes"]} bytes to #{a["path"]}." },
      "execute" => ->(a, r) { "`#{a["command"]}` exited #{r["exit_status"]}." }
    }.freeze

    HELP = <<~TEXT
      I need a model to understand that. Without one, I can do:

          show me README.md
          create notes.txt with hello
          what files are here
          run the tests

      Or type a tool and its arguments. /tools lists them.
      For a model: gem install elelem-llama, then elelem -p llama
    TEXT

    def self.lines(text)
      count = text.to_s.lines.size
      count == 1 ? "1 line" : "#{count} lines"
    end

    def fetch(messages, tools = [], &)
      return report(messages, &) if messages.last[:role] == "tool"

      name, args = understand(messages.last[:content].to_s.lines.first.to_s.strip, tools)
      name ? act(name, args, messages.length, &) : say("I don't understand this request.", HELP, &)
    end

    private

    def understand(text, tools)
      names = tools.map { |t| t.dig(:function, :name) }
      intent(text, names) || direct(text, tools)
    end

    def intent(text, names)
      INTENTS.each do |pattern, name, build|
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

    # A model would not write to "a" when asked to "write a commit message".
    def file_like?(name, args)
      name != "write" || args["path"].to_s.match?(%r{[./]})
    end

    def arguments(tool, rest)
      required = tool.dig(:function, :parameters, :required) || []
      values = rest.split(/\s+/, required.size)
      required.zip(values).to_h.compact.transform_keys(&:to_s)
    end

    def act(name, args, turn)
      thought = THOUGHTS.fetch(name) { ->(_) { "I'll call #{name}." } }
      yield(type: "thinking", text: thought.call(args))
      yield(type: "doing", id: "stub-#{turn}", name: name, arguments: args)
    end

    def report(messages)
      call = messages.rfind { |m| m[:tool_calls] }&.dig(:tool_calls, 0) || {}
      yield(type: "saying", text: summary(call[:name].to_s, call[:arguments] || {}, parse(messages.last[:content])))
    end

    def summary(name, args, result)
      return "#{name} failed: #{result["error"]}. /tools shows what it takes." if result["error"]

      SUMMARIES.fetch(name) { ->(_, r) { r.empty? ? "#{name} is done." : r.map { |k, v| "#{k}: #{v}" }.join("\n") } }
               .call(args, result.except("ok"))
    end

    def parse(content)
      result = JSON.parse(content.to_s)
      result.is_a?(Hash) ? result : { "result" => result }
    rescue JSON::ParserError
      { "result" => content.to_s }
    end

    def say(thought, text)
      yield(type: "thinking", text: thought)
      yield(type: "saying", text: text)
    end
  end
end
