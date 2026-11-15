# frozen_string_literal: true

require "erb"
require "fileutils"
require "forwardable"
require "io/console"
require "json"
require "json_schemer"
require "logger"
require "open3"
require "pathname"
require "stringio"
require "tempfile"

require_relative "elelem/version"
require_relative "elelem/output"
require_relative "elelem/null_output"
require_relative "elelem/input"
require_relative "elelem/null_input"
require_relative "elelem/builtins"
require_relative "elelem/builtins/terminal"
require_relative "elelem/system_prompt"
require_relative "elelem/conversation"
require_relative "elelem/result"
require_relative "elelem/tool"
require_relative "elelem/toolbox"
require_relative "elelem/commands"
require_relative "elelem/agent"
require_relative "elelem/session"
require_relative "elelem/repl"
require_relative "elelem/stub_provider"
require_relative "elelem/plugins"
require_relative "elelem/registry"
require_relative "elelem/config"

module Elelem
  def self.build(provider: "stub", **) = Config.build_session(provider, **)
  def self.start(**) = Repl.new(build(**)).run
  def self.ask(prompt, output: NullOutput.new, **) = build(input: NullInput.new, output:, **).turn(prompt)

  def self.state_dir
    File.join(ENV.fetch("XDG_STATE_HOME", File.expand_path("~/.local/state")), "elelem")
  end

  def self.logger
    @logger ||= Logger.new(log_device, 3, 1_048_576).tap do |log|
      log.level = Logger.const_get(ENV.fetch("ELELEM_LOG_LEVEL", "warn").upcase)
    end
  end

  def self.log_device
    ENV["ELELEM_LOG"] == "-" ? $stderr : log_file
  end

  def self.log_file
    FileUtils.mkdir_p(state_dir, mode: 0o700)
    File.join(state_dir, "elelem.log").tap { |path| File.write(path, "", mode: "a", perm: 0o600) }
  rescue SystemCallError
    $stderr
  end
  private_class_method :log_device, :log_file
end

Elelem.configure { |config| config.provider(:stub) { Elelem::StubProvider.new } }
