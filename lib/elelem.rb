# frozen_string_literal: true

require "erb"
require "fileutils"
require "forwardable"
require "io/console"
require "json"
require "logger"
require "open3"
require "pathname"
require "stringio"
require "tempfile"

require_relative "elelem/version"
require_relative "elelem/private_file"
require_relative "elelem/output"
require_relative "elelem/null_output"
require_relative "elelem/terminal"
require_relative "elelem/input"
require_relative "elelem/null_input"
require_relative "elelem/builtins"
require_relative "elelem/system_prompt"
require_relative "elelem/conversation"
require_relative "elelem/result"
require_relative "elelem/tool"
require_relative "elelem/toolbox"
require_relative "elelem/commands"
require_relative "elelem/agent"
require_relative "elelem/session"
require_relative "elelem/repl"
require_relative "elelem/plugins"
require_relative "elelem/registry"
require_relative "elelem/config"

module Elelem
  OLD_LOGS_KEPT = 3
  LOG_SIZE_LIMIT = 1024 * 1024
  private_constant :OLD_LOGS_KEPT, :LOG_SIZE_LIMIT

  def self.build(provider: "demo", **) = Config.build_session(provider, **)
  def self.start(**) = Repl.new(build(**)).run
  def self.ask(prompt, output: NullOutput.new, **) = build(input: NullInput.new, output:, **).turn(prompt)

  def self.state_dir
    File.join(ENV.fetch("XDG_STATE_HOME", File.expand_path("~/.local/state")), "elelem")
  end

  def self.logger
    @logger ||= Logger.new(log_device, OLD_LOGS_KEPT, LOG_SIZE_LIMIT, level: ENV.fetch("ELELEM_LOG_LEVEL", "warn"))
  end

  def self.log_device
    ENV["ELELEM_LOG"] == "-" ? $stderr : log_file
  end

  def self.log_file
    PrivateFile.new(File.join(state_dir, "elelem.log")).touch.path
  rescue SystemCallError
    $stderr
  end
  private_class_method :log_device, :log_file
end
