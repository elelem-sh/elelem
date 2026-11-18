# frozen_string_literal: true

module Elelem
  module Builtins
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
        @timeout && !Gem.win_platform? ? { chdir: cwd, pgroup: true } : { chdir: cwd }
      end

      def stop_on_interrupt(pid)
        yield
      rescue Interrupt, SystemExit
        Builtins.terminate(pid) if @timeout
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
          Builtins.terminate(process.pid) if @timed_out || !Gem.win_platform?
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
        @timed_out ? 124 : status.exitstatus || 1
      end

      def timeout_note
        @timed_out ? "\n[command timed out after #{@timeout}s]" : ""
      end
    end
    private_constant :Command
  end
end
