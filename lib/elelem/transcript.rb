# frozen_string_literal: true

module Elelem
  class Transcript
    def initialize(template: nil, system_prompt: nil)
      @conversation = Conversation.new
      @template = SystemPrompt.new(template)
      @system_prompt = system_prompt
    end

    def add(role:, content:, **extra)
      @conversation.add(role: role, content: content, **extra)
    end

    def clear!
      @conversation.clear!
    end

    def last
      @conversation.last
    end

    def to_a(extra = [])
      @conversation.to_a(system_prompt: rendered_system_prompt) + extra
    end

    private

    def rendered_system_prompt
      [@system_prompt, @template.render].compact.join("\n\n")
    end
  end
end
