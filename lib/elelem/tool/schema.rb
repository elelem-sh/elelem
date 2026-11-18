# frozen_string_literal: true

module Elelem
  class Tool
    class Schema
      TYPES = {
        "string" => ->(value) { value.is_a?(String) },
        "integer" => ->(value) { value.is_a?(Integer) || (value.is_a?(Float) && (value % 1).zero?) },
        "number" => ->(value) { value.is_a?(Numeric) },
        "boolean" => ->(value) { [true, false].include?(value) },
        "array" => ->(value) { value.is_a?(Array) },
        "object" => ->(value) { value.is_a?(Hash) },
        "null" => :nil?.to_proc
      }.freeze

      Property = Data.define(:name, :types, :enum) do
        def self.parse(name, rule)
          rule = rule.transform_keys(&:to_s)
          types = Array(rule["type"]).map(&:to_s)
          types = [] unless (types - TYPES.keys).empty?
          enum = rule["enum"] if rule["enum"].is_a?(Array)
          new(name: name.to_s, types:, enum:)
        end

        def error(value)
          return "#{name}: expected #{types.join(" or ")}, got #{type_of(value)}" unless type?(value)

          "#{name}: expected one of #{enum.map(&:to_json).join(", ")}" unless enum.nil? || enum.include?(value)
        end

        private

        def type?(value) = types.empty? || types.intersect?(types_of(value))
        def type_of(value) = types_of(value).first || value.class.name
        def types_of(value) = TYPES.select { |_, test| test.call(value) }.keys
      end

      ARGUMENTS = Property.new(name: "arguments", types: ["object"], enum: nil)

      attr_reader :to_h

      def initialize(params, required)
        @to_h = { type: "object", properties: params.freeze, required: required.freeze }.freeze
        @required = Array(required).filter_map { |key| key.to_s if key in String | Symbol }
        @properties = Hash.try_convert(params).to_h.filter_map do |name, rule|
          Property.parse(name, rule) if rule.is_a?(Hash)
        end
      end

      def errors(args)
        args = {} if args.nil?
        malformed = ARGUMENTS.error(args)
        return [malformed] if malformed

        [missing(args), *mismatches(args)].compact
      end

      private

      def mismatches(args)
        @properties.filter_map { |property| property.error(args[property.name]) if args.key?(property.name) }
      end

      def missing(args)
        keys = @required - args.keys
        "missing required: #{keys.join(", ")}" if keys.any?
      end
    end
    private_constant :Schema
  end
end
