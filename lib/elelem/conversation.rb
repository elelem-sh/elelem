# frozen_string_literal: true

module Elelem
  class Conversation
    ROLES = %w[user assistant].freeze

    def initialize(template: nil, system_prompt: nil)
      @messages = []
      @template = SystemPrompt.new(template)
      @role_text = system_prompt
    end

    def add(role:, content:)
      raise ArgumentError, "invalid role: #{role}" unless ROLES.include?(role)

      @messages << { role: role, content: content }
    end

    def last = @messages.last
    def clear! = @messages.clear

    def to_a(extra = [])
      system = [@role_text, @template.render].compact.join("\n\n")
      [{ role: "system", content: system }, *@messages, *extra]
    end
  end
end
