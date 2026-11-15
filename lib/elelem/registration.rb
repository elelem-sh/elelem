# frozen_string_literal: true

module Elelem
  class Registration
    attr_reader :providers, :setups, :factories

    def initialize
      @providers = {}
      @setups = {}
      @factories = {}
    end

    def provider(name, &factory)
      @providers[name.to_s] = factory
      self
    end

    def setup(name, &block)
      @setups[name.to_s] = block
      self
    end

    def input(&factory)
      @factories[:input] = factory
      self
    end

    def output(&factory)
      @factories[:output] = factory
      self
    end

    # Drops setups defined in files under dirs. Gem setups are kept, since
    # require will not run them again.
    def clear_setups_from!(dirs)
      @setups.reject! do |_, block|
        file = block.source_location&.first.to_s
        dirs.any? { |dir| file.start_with?("#{dir}/") }
      end
    end
  end
end
