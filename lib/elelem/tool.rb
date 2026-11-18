# frozen_string_literal: true

module Elelem
  class Tool
    TYPES = {
      "string" => ->(value) { value.is_a?(String) },
      "integer" => ->(value) { value.is_a?(Integer) || (value.is_a?(Float) && (value % 1).zero?) },
      "number" => ->(value) { value.is_a?(Numeric) },
      "boolean" => ->(value) { [true, false].include?(value) },
      "array" => ->(value) { value.is_a?(Array) },
      "object" => ->(value) { value.is_a?(Hash) },
      "null" => :nil?.to_proc
    }.freeze
    private_constant :TYPES

    attr_reader :name, :description, :aliases

    def initialize(name, description:, params: {}, required: [], aliases: [], &handler)
      @name = name
      @description = description
      @aliases = aliases.freeze
      @handler = handler
      @schema = { type: "object", properties: params.freeze, required: required.freeze }.freeze
    end

    def call(args) = @handler.call(args)
    def inspect = "#<#{self.class} #{name}>"
    def to_h = { type: "function", function: { name: name, description: description, parameters: @schema } }

    def validate(args)
      args = {} if args.nil?
      return ["arguments: expected object, got #{type_of(args)}"] unless args.is_a?(Hash)

      [missing(args), *rules.map { |key, rule| mismatch(key, args[key], rule) if args.key?(key) }].compact
    end

    private

    def missing(args)
      keys = Array(@schema[:required]).filter_map { |key| key.to_s if key in String | Symbol } - args.keys
      "missing required: #{keys.join(", ")}" if keys.any?
    end

    def rules
      Hash.try_convert(@schema[:properties]).to_h.filter_map do |key, rule|
        [key.to_s, rule.transform_keys(&:to_s)] if rule.is_a?(Hash)
      end
    end

    def mismatch(key, value, rule)
      types = Array(rule["type"]).map(&:to_s)
      enum = rule["enum"]
      return "#{key}: expected #{types.join(" or ")}, got #{type_of(value)}" unless type?(value, types)

      "#{key}: expected one of #{enum.map(&:to_json).join(", ")}" if enum.is_a?(Array) && !enum.include?(value)
    end

    def type?(value, types) = types.empty? || unknown_type?(types) || types.intersect?(types_of(value))
    def unknown_type?(types) = (types - TYPES.keys).any?
    def type_of(value) = types_of(value).first || value.class.name
    def types_of(value) = TYPES.select { |_, test| test.call(value) }.keys
  end
end
