# frozen_string_literal: true

module Elelem
  # /provider NAME [MODEL]. The session's own options, such as --model, carry
  # over only to the provider they were given for.
  class ProviderSwitch
    def initialize(session)
      @session = session
    end

    def call(name, model = nil)
      options = options_for(name, model)
      @session.provider = Config.build_provider(name, **options)
      @session.provider_name = name
      @session.provider_options = options
    end

    private

    def options_for(name, model)
      return { model: model } if model

      name == @session.provider_name ? @session.provider_options : {}
    end
  end
end
