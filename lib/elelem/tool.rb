# frozen_string_literal: true

require_relative "tool/schema"

module Elelem
  class Tool
    attr_reader :name, :description, :aliases

    def initialize(name, description:, params: {}, required: [], aliases: [], &handler)
      @name = name
      @description = description
      @aliases = aliases.freeze
      @handler = handler
      @schema = Schema.new(params, required)
    end

    def call(args) = @handler.call(args)
    def validate(args) = @schema.errors(args)
    def inspect = "#<#{self.class} #{name}>"
    def to_h = { type: "function", function: { name: name, description: description, parameters: @schema.to_h } }
  end
end
