# frozen_string_literal: true

module Elelem
  module Builtins
    class Command
      def initialize(timeout:)
        @timeout = timeout
        @timed_out = false
        @output = StringIO.new
      end

      def run(argv, env:, cwd:, &)
        Open3.popen2e(env, *argv, **spawn_options(cwd)) do |stdin, out, process|
          stdin.close
          stop_on_interrupt(process) { finish(process, out, &) }
        end
      end

      private

      def spawn_options(cwd)
        own_group? ? { chdir: cwd, pgroup: true } : { chdir: cwd }
      end

      def own_group? = @timeout && !Gem.win_platform?

      def stop_on_interrupt(process)
        yield
      rescue Interrupt, SystemExit
        stop(process) if @timeout
        raise
      end

      def finish(process, out, &)
        watchdog = start_watchdog(process)
        stream_lines(out, &)
        @timed_out ? watchdog.join : watchdog&.kill
        { exit_status: exit_status(process.value), content: Builtins.truncate(@output.string) + timeout_note }
      end

      def start_watchdog(process)
        @timeout && Thread.new do
          sleep(@timeout)
          @timed_out = process.alive?
          stop(process) if @timed_out || own_group?
        end
      end

      def stop(process)
        own_group? ? kill_group(process.pid) : taskkill(process.pid)
      end

      def kill_group(pid)
        Process.kill("TERM", -pid)
        sleep 0.5
        Process.kill("KILL", -pid)
      rescue Errno::ESRCH
        nil
      end

      def taskkill(pid) = system("taskkill", "/T", "/F", "/PID", pid.to_s, out: File::NULL, err: File::NULL)

      def stream_lines(out)
        out.each_line do |line|
          line = line.force_encoding(Encoding::UTF_8).scrub
          yield line if block_given?
          @output.write(line)
        end
      end

      def exit_status(status)
        @timed_out ? 124 : status.exitstatus || 1
      end

      def timeout_note
        @timed_out ? "\n[command timed out after #{@timeout}s]" : ""
      end
    end
    private_constant :Command
  end
end
