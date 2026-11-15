# frozen_string_literal: true

module Elelem
  class Repl
    def initialize(session)
      @session = session
    end

    def run
      @session.output.say "elelem v#{VERSION}"
      while (line = @session.input.ask("> "))
        dispatch_line(line) unless line.empty?
      end
    end

    private

    # Only lines typed at the prompt go in history, not answers to a tool.
    def remember(line)
      input = @session.input
      input.remember(line) if input.respond_to?(:remember)
    end

    def dispatch_line(line)
      remember(line)
      line.start_with?("/") ? command(line) : @session.turn(line)
    end

    def command(line)
      name, args = line.delete_prefix("/").split(" ", 2)
      @session.commands.run(name, args) || @session.output.say(@session.commands.names.join(" "))
    rescue StandardError, ScriptError => e
      warn_and_say(e)
    end

    def warn_and_say(error)
      Elelem.logger.debug("repl: #{error.message}")
      @session.output.say(error.message, as: :error)
    end
  end
end
