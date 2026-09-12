# frozen_string_literal: true

module Elelem
  class Transcript
    def initialize(system_prompt: nil)
      @conversation = Conversation.new
      @system_prompt = SystemPrompt.new(system_prompt)
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
      @conversation.to_a(system_prompt: @system_prompt.render) + extra
    end
  end
end
