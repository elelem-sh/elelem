# frozen_string_literal: true

module Elelem
  class SystemPrompt
    DEFAULT = File.read(File.expand_path("prompts/default.erb", __dir__)).freeze
    USER_AGENTS_MD = Pathname.new(Dir.home).join(".agents/AGENTS.md").freeze

    attr_accessor :template

    def initialize(template = nil)
      @template = template || DEFAULT
    end

    def render
      ERB.new(template, trim_mode: "-").result(binding)
    end

    private

    def agents_md
      [global_agents_md, project_agents_md].compact.then { |parts| parts.empty? ? nil : parts.join("\n\n") }
    end

    def global_agents_md
      USER_AGENTS_MD.read if USER_AGENTS_MD.exist?
    end

    def project_agents_md
      Pathname.pwd.ascend.each do |dir|
        file = dir / "AGENTS.md"
        return file.read if file.exist?
      end
      nil
    end
  end
end
