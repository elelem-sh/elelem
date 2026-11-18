# frozen_string_literal: true

require_relative "builtins/command"
require_relative "builtins/shell"
require_relative "builtins/terminal"

module Elelem
  module Builtins
    def self.sh(cmd, args: [], cwd: Dir.pwd, env: {}, timeout: nil, &)
      Command.new(timeout:).run([cmd, *args], env:, cwd:, &)
    end

    def self.truncate(content, limit: 10_000)
      return content if content.length <= limit

      half = limit / 2
      elided = content.length - limit
      "#{content[0, half]}\n[#{elided} characters elided]\n#{content[-half, half]}"
    end

    def self.shell = finder.name

    def self.shell_command(command) = finder.argv(command)

    def self.finder = @finder ||= Shell.new

    def self.finder=(shell)
      @finder = shell
    end
    private_class_method :finder
  end
end
