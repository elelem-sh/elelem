# frozen_string_literal: true

module Elelem
  module Builtins
    class Terminal
      def initialize(stream: $stdout, **)
        @stream = stream
        @dots_thread = nil
        @at_line_start = true
      end

      def say(text, as: nil)
        stop_dots
        return if blank?(text)

        text = render(text, as) if as
        write "#{text}\n"
        @at_line_start = true
      end

      def print(text)
        stop_dots
        return if blank?(text)

        write text
        @at_line_start = false
      end

      def thinking(text)
        print("\e[2;3m#{text}\e[0m") unless blank?(text)
      end

      def doing(name, args, state: "+")
        gap
        say "#{state} \e[36m#{name}\e[0m(#{args})"
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
        system("bat", "--paging=never", path) || say(fallback || path)
      end

      private

      def render(text, as)
        return "\n  ✗ #{text}" if as == :error
        return text unless as == :markdown

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
        @at_line_start = true
      end

      def stop_dots
        return unless @dots_thread

        @dots_thread[:stop] = true
        @dots_thread.join
        @dots_thread = nil
        write("\n")
        @at_line_start = true
      end

      def write(text)
        @stream.print text
        (@transcript ||= open_transcript).print text
      end

      def open_transcript
        state_dir = File.join(ENV.fetch("XDG_STATE_HOME", File.expand_path("~/.local/state")), "elelem", "sessions")
        FileUtils.mkdir_p(state_dir)
        session_id = "#{Time.now.utc.strftime("%Y%m%dT%H%M%SZ")}-#{Process.pid}"
        File.open(File.join(state_dir, "#{session_id}.transcript"), "a").tap { |f| f.sync = true } # rubocop:disable Style/FileOpen
      end

      def blank?(text)
        text.nil? || text.to_s.strip.empty?
      end
    end
  end
end
