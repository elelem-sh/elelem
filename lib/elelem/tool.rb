# frozen_string_literal: true

module Elelem
  class Tool
    attr_reader :name, :description, :aliases

    # params and required are JSON Schema; every call is checked against them.
    def initialize(name, description:, params: {}, required: [], aliases: [], &handler)
      @name = name
      @description = description
      @aliases = aliases.freeze
      @handler = handler
      @schema = { type: "object", properties: params.freeze, required: required.freeze }.freeze
    end

    def call(args) = @handler.call(args)
    def validate(args) = (@validator ||= JSONSchemer.schema(@schema)).validate(args || {}).map { |e| e["error"] }
    def inspect = "#<#{self.class} #{name}>"
    def to_h = { type: "function", function: { name: name, description: description, parameters: @schema } }
  end
end
