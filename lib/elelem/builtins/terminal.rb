# frozen_string_literal: true

module Elelem
  module Builtins
    # Output for a person at a terminal: dots while the model thinks, markdown
    # through glow, files through bat, and a copy of everything in a private
    # transcript under $XDG_STATE_HOME/elelem/sessions.
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
        @dots_thread = Thread.new do
          until Thread.current[:stop]
            @stream.print "."
            @stream.flush
            sleep 0.1
          end
        end
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
        width = begin
          @stream.winsize[1]
        rescue StandardError
          80
        end
        IO.popen(["glow", "-s", "dark", "-w", width.to_s, "-"], "r+") do |io|
          io.write(text)
          io.close_write
          io.read
        end
      rescue Errno::ENOENT
        text
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
        state_dir = File.join(ENV.fetch("XDG_STATE_HOME", File.expand_path("~/.local/state")), "elelem", "sessions")
        FileUtils.mkdir_p(state_dir, mode: 0o700)
        File.chmod(0o700, state_dir)
        session_id = "#{Time.now.utc.strftime("%Y%m%dT%H%M%SZ")}-#{Process.pid}"
        path = File.join(state_dir, "#{session_id}.transcript")
        File.open(path, "a", 0o600).tap { |f| f.sync = true } # rubocop:disable Style/FileOpen
      end
    end
  end
end
