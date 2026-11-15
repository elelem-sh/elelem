# frozen_string_literal: true

require "reline"

module Elelem
  class Input
    def initialize(commands: Commands.new)
      @commands = commands
      Reline.autocompletion = true
      Reline.completion_proc = ->(target, preposing) { complete(target, preposing) }
    end

    def ask(prompt)
      Reline.readline(prompt, false)&.strip
    end

    def remember(line)
      Reline::HISTORY << line
    end

    def interactive?
      $stdin.tty?
    end

    private

    def complete(target, preposing)
      line = "#{preposing}#{target}"
      return @commands.names.select { |c| c.start_with?(line) } if line.start_with?("/") && !preposing.include?(" ")
      return complete_command_args(preposing, target) if preposing.start_with?("/") && preposing.include?(" ")

      complete_files(target)
    end

    def complete_command_args(preposing, target)
      @commands.completions_for(preposing.delete_prefix("/").split(" ", 2).first, target)
    end

    def complete_files(target)
      dir = target.include?("/") ? target[..target.rindex("/")] : ""
      entries(dir).map { |name| "#{dir}#{name}" }.select { |path| path.start_with?(target) }.sort.first(20)
    end

    def entries(dir)
      Dir.children(dir.empty? ? "." : dir)
    rescue SystemCallError
      []
    end
  end
end
