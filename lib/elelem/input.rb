# frozen_string_literal: true

require "reline"

module Elelem
  class Input
    def initialize(commands: [])
      @commands = commands
      Reline.autocompletion = true
      Reline.completion_proc = ->(target, preposing) { complete(target, preposing) }
    end

    def ask(prompt)
      Reline.readline(prompt, true)&.strip
    end

    def interactive?
      $stdin.tty?
    end

    private

    def complete(target, preposing)
      line = "#{preposing}#{target}"
      return command_names.select { |c| c.start_with?(line) } if line.start_with?("/") && !preposing.include?(" ")
      return complete_command_args_for(preposing, target) if preposing.start_with?("/") && preposing.include?(" ")

      complete_files(target)
    end

    def complete_command_args_for(preposing, target)
      cmd_name = preposing.delete_prefix("/").split(" ", 2).first
      complete_command_args(cmd_name, target)
    end

    def command_names
      @commands.respond_to?(:names) ? @commands.names : @commands
    end

    def complete_command_args(cmd_name, partial)
      return [] unless @commands.respond_to?(:completions_for)

      @commands.completions_for(cmd_name, partial)
    end

    def complete_files(target)
      output, = Open3.capture2("bash", "-c", "compgen -f #{Shellwords.escape(target)}")
      output.lines.map(&:strip).first(20)
    end
  end
end
