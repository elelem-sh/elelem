# frozen_string_literal: true

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
          line = line.force_encoding(Encoding::UTF_8).scrub
          yield line if block_given?
          output.write(line)
        end
        timed_out ? watchdog&.join : watchdog&.kill

        status = wait_thr.value
        note = timed_out ? "\n[command timed out after #{timeout}s]" : ""
        { exit_status: status.exitstatus || (timed_out ? 124 : 1), content: truncate(output.string) + note }
      rescue Interrupt
        # In its own process group the command never sees Ctrl-C, so stop it here.
        terminate(wait_thr.pid) if timeout
        raise
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
  end
end
