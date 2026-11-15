# frozen_string_literal: true

module Elelem
  class Agent
    attr_reader :conversation, :toolbox, :output
    attr_accessor :provider

    def initialize(provider, toolbox: Toolbox.new, output: NullOutput.new, template: nil, system_prompt: nil)
      @provider = provider
      @toolbox = toolbox
      @output = output
      @conversation = Conversation.new(template: template, system_prompt: system_prompt)
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
      [String.new, []].tap do |content, tool_calls|
        provider.fetch(@conversation.to_a(ctx), toolbox.to_a) { |event| handle_event(event, content, tool_calls) }
        output.say(content, as: :markdown)
      end
    end

    def handle_event(event, content, tool_calls)
      case event[:type]
      when "saying" then content << event[:text].to_s
      when "thinking" then output.thinking(event[:text])
      when "doing" then tool_calls << { id: event[:id], name: event[:name], arguments: event[:arguments] }
      end
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
