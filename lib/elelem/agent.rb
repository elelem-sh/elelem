# frozen_string_literal: true

module Elelem
  class Agent
    attr_reader :conversation, :toolbox, :output
    attr_accessor :provider

    def initialize(provider, toolbox: Toolbox.new, output: NullOutput.new, template: nil, system_prompt: nil)
      @provider = provider
      @toolbox = toolbox
      @output = output
      @conversation = Transcript.new(template: template, system_prompt: system_prompt)
    end

    def context
      @conversation.to_a
    end

    def turn(prompt)
      @conversation.add(role: "user", content: prompt)
      content = run_until_done([])
      @conversation.add(role: "assistant", content: content)
      content
    end

    private

    def run_until_done(ctx)
      loop do
        content, tool_calls = fetch_and_say(ctx)
        return content if tool_calls.empty?

        ctx.concat(tool_turn(content, tool_calls))
      end
    end

    def fetch_and_say(ctx)
      output.waiting
      content, tool_calls = fetch_response(ctx)
      output.say(content, as: :markdown)
      [content, tool_calls]
    end

    def tool_turn(content, tool_calls)
      results = tool_calls.map { |tool_call| tool_result(tool_call) }
      [{ role: "assistant", content: content, tool_calls: tool_calls }.compact, *results]
    end

    def tool_result(tool_call)
      { role: "tool", tool_call_id: tool_call[:id], content: process(tool_call).to_json }
    end

    def process(tool_call)
      name = tool_call[:name]
      args = tool_call[:arguments]
      output.doing(toolbox.tool_for(name).name, args)
      Elelem.logger.debug("agent: #{name}(#{args.inspect})")
      log_result(name, toolbox.run(name.to_s, args))
    end

    def log_result(name, result)
      Elelem.logger.debug("agent: #{name} -> #{result.inspect}")
      result
    end

    def fetch_response(ctx)
      collect_response(ctx)
    rescue StandardError, ScriptError => e
      fetch_error(e)
    end

    def collect_response(ctx)
      content = String.new
      tool_calls = []
      provider.fetch(messages(ctx), toolbox.to_a) { |event| handle_event(event, content, tool_calls) }
      [content, tool_calls]
    end

    def messages(ctx)
      @conversation.to_a(ctx)
    end

    def fetch_error(error)
      warn_and_say(error)
      ["Error: #{error.message}", []]
    end

    def handle_event(event, content, tool_calls)
      case event[:type]
      when "saying" then content << event[:text].to_s
      when "thinking" then output.thinking(event[:text])
      when "doing" then tool_calls << { id: event[:id], name: event[:name], arguments: event[:arguments] }
      end
    end

    def warn_and_say(error)
      Elelem.logger.debug("agent: #{error.message}")
      output.say(error.message, as: :error)
    end
  end
end
