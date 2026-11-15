# frozen_string_literal: true

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

    class Command
      def initialize(timeout)
        @timeout = timeout
        @timed_out = false
        @output = StringIO.new
      end

      def run(env, argv, cwd, &)
        Open3.popen2e(env, *argv, **spawn_options(cwd)) do |stdin, out, process|
          stdin.close
          stop_on_interrupt(process.pid) { finish(process, out, &) }
        end
      end

      private

      def spawn_options(cwd)
        @timeout ? { chdir: cwd, pgroup: true } : { chdir: cwd }
      end

      def stop_on_interrupt(pid)
        yield
      rescue Interrupt, SystemExit
        Builtins.terminate(pid) if @timeout
        raise
      end

      def finish(process, out, &)
        watchdog = start_watchdog(process.pid)
        stream_lines(out, &)
        @timed_out ? watchdog.join : watchdog&.kill
        { exit_status: exit_status(process.value), content: Builtins.truncate(@output.string) + timeout_note }
      end

      def start_watchdog(pid)
        @timeout && Thread.new do
          sleep(@timeout)
          @timed_out = true
          Builtins.terminate(pid)
        end
      end

      def stream_lines(out)
        out.each_line do |line|
          line = line.force_encoding(Encoding::UTF_8).scrub
          yield line if block_given?
          @output.write(line)
        end
      end

      def exit_status(status)
        status.exitstatus || (@timed_out ? 124 : 1)
      end

      def timeout_note
        @timed_out ? "\n[command timed out after #{@timeout}s]" : ""
      end
    end
    private_constant :Command
  end
end
