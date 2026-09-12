# frozen_string_literal: true

module Elelem
  module Config
    extend SingleForwardable

    def_single_delegators :default, :build_provider, :build_session, :apply, :reload, :names

    def self.default
      @default ||= Registry.new
    end
  end

  def self.configure(&)
    Config.default.configure(&)
  end
end
