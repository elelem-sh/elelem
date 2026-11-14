# frozen_string_literal: true

require "erb"
require "forwardable"
require "json"
require "json_schemer"
require "logger"
require "open3"
require "pathname"
require "shellwords"

require_relative "elelem/agent"
require_relative "elelem/builtins"
require_relative "elelem/slash_command"
require_relative "elelem/commands"
require_relative "elelem/conversation"
require_relative "elelem/input"
require_relative "elelem/null_input"
require_relative "elelem/output"
require_relative "elelem/null_output"
require_relative "elelem/plugins"
require_relative "elelem/registration"
require_relative "elelem/registry"
require_relative "elelem/repl"
require_relative "elelem/config"
require_relative "elelem/result"
require_relative "elelem/schema"
require_relative "elelem/session"
require_relative "elelem/stub_provider"
require_relative "elelem/system_prompt"
require_relative "elelem/tool"
require_relative "elelem/transcript"
require_relative "elelem/null_tool"
require_relative "elelem/toolbox"
require_relative "elelem/version"

module Elelem
  def self.start(provider: "stub", toolbox: Toolbox.new, provider_options: {}, template: nil, system_prompt: nil)
    Repl.new(build(provider: provider, toolbox: toolbox, provider_options: provider_options, template: template,
                   system_prompt: system_prompt)).run
  end

  def self.ask(prompt, provider: "stub", toolbox: Toolbox.new, output: NullOutput.new, provider_options: {},
               template: nil, system_prompt: nil)
    build(provider: provider, toolbox: toolbox, input: NullInput.new, output: output,
          provider_options: provider_options, template: template, system_prompt: system_prompt).turn(prompt)
  end

  def self.build(provider: "stub", toolbox: Toolbox.new, input: nil, output: nil, provider_options: {},
                 template: nil, system_prompt: nil)
    Config.build_session(provider, toolbox: toolbox, input: input, output: output,
                                   provider_options: provider_options, template: template, system_prompt: system_prompt)
  end

  def self.logger
    @logger ||= Logger.new($stderr).tap do |log|
      log.level = Logger.const_get(ENV.fetch("ELELEM_LOG_LEVEL", "warn").upcase)
    end
  end
end

Elelem.configure { |config| config.provider(:stub) { Elelem::StubProvider.new } }
