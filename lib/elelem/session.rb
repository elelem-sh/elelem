# frozen_string_literal: true

module Elelem
  class Session
    extend Forwardable

    attr_reader :agent, :input, :commands
    # The provider the session was built with, and its options (such as --model).
    attr_accessor :provider_name, :provider_options

    def_delegators :@agent, :provider, :provider=, :toolbox, :output, :conversation, :context, :turn

    def initialize(agent, input: NullInput.new, commands: Commands.new, provider_name: nil, provider_options: {})
      @agent = agent
      @input = input
      @commands = commands
      @provider_name = provider_name&.to_s
      @provider_options = provider_options
    end
  end
end
