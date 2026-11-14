# frozen_string_literal: true

module Elelem
  class Tool
    attr_reader :name, :description, :aliases

    def initialize(name, description:, schema: Schema.new, aliases: [], &handler)
      @name = name
      @description = description
      @schema = schema
      @aliases = aliases.freeze
      @handler = handler
    end

    def call(args)
      @handler.call(args)
    end

    def validate(args)
      @schema.validate(args)
    end

    def inspect = "#<#{self.class} #{name}>"

    def to_h
      {
        type: "function",
        function: {
          name: name,
          description: description,
          parameters: @schema.to_h
        }
      }
    end
  end
end
