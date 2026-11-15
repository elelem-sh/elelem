# frozen_string_literal: true

module Elelem
  module Builtins
    class Terminal < Output
      def initialize(stream: $stdout, **)
        super
        @dots_thread = nil
        @at_line_start = true
      end

      def say(text, as: nil)
        stop_dots
        super
      end

      def print(text)
        stop_dots
        super
      end

      def doing(name, args, state: "+")
        gap
        super
      end

      def waiting
        stop_dots
        @dots_thread = Thread.new { print_dots_until_stopped }
      end

      def display_file(path, fallback: nil)
        system("bat", "--paging=never", "--", path) || super
      end

      private

      def render(text, as)
        case as
        when :error then "\n  x #{text}"
        when :markdown then markdown(text)
        else text
        end
      end

      def markdown(text)
        gap
        IO.popen(["glow", "-s", "dark", "-w", terminal_width.to_s, "-"], "r+") { |glow| filter(glow, text) }
      rescue Errno::ENOENT
        text
      end

      def filter(io, text)
        io.write(text)
        io.close_write
        io.read
      end

      def terminal_width
        @stream.winsize[1]
      rescue StandardError
        80
      end

      def print_dots_until_stopped
        until Thread.current[:stop]
          @stream.print "."
          @stream.flush
          sleep 0.1
        end
      end

      def gap
        stop_dots
        write("\n") unless @at_line_start
      end

      def stop_dots
        return unless @dots_thread

        @dots_thread[:stop] = true
        @dots_thread.join
        @dots_thread = nil
        write("\n")
      end

      def write(text)
        @stream.print text
        @at_line_start = text.end_with?("\n")
        (@transcript ||= open_transcript).print text
      end

      def open_transcript
        File.open(transcript_path, "a", 0o600).tap { |f| f.sync = true } # rubocop:disable Style/FileOpen
      end

      def transcript_path
        dir = File.join(Elelem.state_dir, "sessions")
        FileUtils.mkdir_p(dir, mode: 0o700)
        File.chmod(0o700, dir)
        File.join(dir, "#{Time.now.utc.strftime("%Y%m%dT%H%M%SZ")}-#{Process.pid}.transcript")
      end
    end
  end
end
