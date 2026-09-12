# frozen_string_literal: true

module Elelem
  class Schema
    def initialize(params: {}, required: [])
      @params = params.freeze
      @required = required.freeze
      @schema_hash = { type: "object", properties: @params, required: @required }.freeze
      @json_schemer = JSONSchemer.schema(@schema_hash)
    end

    def to_h
      @schema_hash
    end

    def validate(args)
      @json_schemer.validate(args || {}).map { |error| error["error"] }
    end
  end
end
