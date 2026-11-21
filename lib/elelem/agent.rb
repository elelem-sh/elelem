# frozen_string_literal: true

module Elelem
  class Agent
    attr_reader :conversation, :toolbox, :output
    attr_accessor :provider

    def initialize(provider, toolbox: Toolbox.new, output: NullOutput.new, template: nil, system_prompt: nil)
      @provider = provider
      @toolbox = toolbox
      @output = output
      @conversation = Conversation.new(template:, system_prompt:)
    end

    def turn(prompt)
      message = { role: "user", content: prompt }
      content = run_until_done([message])
      @conversation.add(**message)
      @conversation.add(role: "assistant", content: content)
      content
    end

    private

    def run_until_done(ctx)
      loop do
        content, tool_calls = fetch(ctx)
        return content if tool_calls.empty?

        ctx.push({
          role: "assistant",
          content: content,
          tool_calls: tool_calls
        }, *tool_calls.map { |c| process(c) })
      end
    end

    def fetch(ctx)
      output.waiting
      events = stream(ctx)
      content = events.filter_map { |e| e[:text] if e[:type] == "saying" }.join
      output.say(content, as: :markdown)
      [content, events.filter_map { |e| e.slice(:id, :name, :arguments) if e[:type] == "doing" }]
    end

    def stream(ctx)
      [].tap do |events|
        provider.fetch(@conversation.to_a(ctx), toolbox.to_a) do |event|
          events << event.tap { show_thinking(it) }
        end
      end
    end

    def show_thinking(event)
      output.thinking(event[:text]) if event[:type] == "thinking"
    end

    def process(call)
      name, args = call.values_at(:name, :arguments)
      output.doing(toolbox.tool_for(name)&.name || "#{name}?", args)
      result = toolbox.run(name.to_s, args).to_json
      Elelem.logger.debug("agent: #{name}(#{args.inspect}) -> #{result}")
      { role: "tool", tool_call_id: call[:id], content: result }
    end
  end
end
