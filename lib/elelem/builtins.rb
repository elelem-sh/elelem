# frozen_string_literal: true

require_relative "builtins/command"
require_relative "builtins/terminal"

module Elelem
  module Builtins
    def self.sh(cmd, args: [], cwd: Dir.pwd, env: {}, timeout: nil, &)
      Command.new(timeout).run(env, [cmd, *args], cwd, &)
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
  end
end
