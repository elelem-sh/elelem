# frozen_string_literal: true

module Elelem
  class Commands
    include Enumerable

    Command = Struct.new(:description, :completions, :handler)

    def initialize
      @registry = {}
    end

    def clear!
      @registry.clear
    end

    def register(name, description: "", completions: nil, &handler)
      @registry[name] = Command.new(description, completions, handler)
    end

    def completions_for(name, partial = "")
      options = @registry[name]&.completions || []
      options = options.call if options.respond_to?(:call)
      options.select { |o| o.start_with?(partial) }
    end

    def run(name, args = nil)
      command = @registry[name]
      return false unless command

      command.handler.call(args)
      true
    end

    def names
      @registry.keys.map { |name| "/#{name}" }
    end

    def each
      @registry.each { |name, command| yield "/#{name}", command.description }
    end
  end
end
