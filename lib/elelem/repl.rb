# frozen_string_literal: true

module Elelem
  class Repl
    def initialize(session, provider: nil, model: nil)
      @session = session
      @provider = provider
      @model = model
    end

    def run
      @session.output.say banner
      while (line = @session.input.ask("> "))
        dispatch_line(line) unless line.empty?
      end
    end

    private

    def banner
      model = @session.provider.respond_to?(:model) ? @session.provider.model : @model
      using = "#{@provider}#{" (#{model})" if model}" if @provider
      ["elelem v#{VERSION}", using, "/help"].compact.join(" · ")
    end

    def dispatch_line(line)
      @session.input.remember(line) if @session.input.respond_to?(:remember)
      command(line) || @session.turn(line)
    rescue StandardError, ScriptError => e
      Elelem.logger.warn("repl: #{e.message}\n#{e.backtrace.join("\n")}")
      @session.output.say(e.message, as: :error)
    end

    def command(line)
      name, args = line.delete_prefix("/").split(" ", 2)
      line.start_with?("/") && @session.commands.run(name, args)
    end
  end
end
