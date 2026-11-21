# frozen_string_literal: true

module Elelem
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
      sleep 0.1
      until Thread.current[:stop]
        print_dot
        sleep 0.1
      end
    end

    def print_dot
      @stream.print "."
      @stream.flush
      @at_line_start = false
    end

    def gap
      stop_dots
      end_line
    end

    def stop_dots
      return unless @dots_thread

      @dots_thread[:stop] = true
      @dots_thread.join
      @dots_thread = nil
      end_line
    end

    def end_line
      write("\n") unless @at_line_start
    end

    def write(text)
      @stream.print text
      @at_line_start = text.end_with?("\n")
      transcript << text
    end

    def transcript = @transcript ||= PrivateFile.new(transcript_path, own_dir: true)

    def transcript_path = File.join(Elelem.state_dir, "sessions", "#{started_at}-#{Process.pid}.transcript")

    def started_at = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
  end
end
