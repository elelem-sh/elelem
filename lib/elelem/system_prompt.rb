# frozen_string_literal: true

module Elelem
  class SystemPrompt
    DEFAULT = File.read(File.expand_path("prompts/default.erb", __dir__)).freeze
    USER_AGENTS_MD = Pathname.new(Dir.home).join(".agents/AGENTS.md").freeze

    attr_reader :template

    def initialize(template = nil)
      @template = template || DEFAULT
    end

    def render
      ERB.new(template, trim_mode: "-").result(binding)
    end

    private

    def agents_md
      parts = [USER_AGENTS_MD, nearest_agents_md].compact.select(&:exist?).map(&:read)
      parts.join("\n\n") unless parts.empty?
    end

    def nearest_agents_md = Pathname.pwd.ascend.map { |dir| dir / "AGENTS.md" }.find(&:exist?)
  end
end
