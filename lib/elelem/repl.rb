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

    def dispatch_line(line)
      @session.input.remember(line) if @session.input.respond_to?(:remember)
      command(line) || @session.turn(line)
    rescue StandardError, ScriptError => e
      Elelem.logger.debug("repl: #{e.message}")
      @session.output.say(e.message, as: :error)
    end

    def command(line)
      name, args = line.delete_prefix("/").split(" ", 2)
      line.start_with?("/") && @session.commands.run(name, args)
    end
  end
end
