# frozen_string_literal: true

module Elelem
  class Session
    extend Forwardable

    attr_reader :agent, :input, :commands

    def_delegators :@agent, :provider, :provider=, :toolbox, :output, :conversation, :context, :turn

    def initialize(agent, input: NullInput.new, commands: Commands.new)
      @agent = agent
      @input = input
      @commands = commands
    end
  end
end
