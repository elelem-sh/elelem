# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "stringio"
require "tempfile"

module Elelem
  module Builtins
    def self.sh(cmd, args: [], cwd: Dir.pwd, env: {}, timeout: nil)
      output = StringIO.new
      options = { chdir: cwd }
      options[:pgroup] = true if timeout

      Open3.popen2e(env, cmd, *args, **options) do |stdin, out, wait_thr|
        stdin.close
        timed_out = false
        watchdog = timeout && Thread.new do
          sleep(timeout)
          timed_out = true
          terminate(wait_thr.pid)
        end

        out.each_line do |line|
          yield line if block_given?
          output.write(line)
        end
        timed_out ? watchdog&.join : watchdog&.kill

        status = wait_thr.value
        note = timed_out ? "\n[command timed out after #{timeout}s]" : ""
        { exit_status: status.exitstatus || (timed_out ? 124 : 1), content: truncate(output.string) + note }
      end
    end

    def self.truncate(content, limit: 10_000)
      return content if content.length <= limit

      half = limit / 2
      elided = content.length - limit
      "#{content[0, half]}\n[#{elided} characters elided]\n#{content[-half, half]}"
    end

    def self.terminate(pid)
      Process.kill("TERM", -pid)
      sleep 0.5
      Process.kill("KILL", -pid)
    rescue Errno::ESRCH
      nil
    end

    def self.command_timeout
      value = ENV.fetch("ELELEM_CMD_TIMEOUT", nil)
      value && !value.empty? ? Integer(value) : nil
    end
  end
end

require_relative "builtins/terminal"
require_relative "builtins/tool_markdown"
