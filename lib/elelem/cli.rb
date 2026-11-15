# frozen_string_literal: true

require "elelem"
require "optparse"

module Elelem
  class CLI
    COMMANDS = %w[chat ask help].freeze
    USAGE = <<~TEXT.freeze
      Usage: #{File.basename($PROGRAM_NAME)} [command] [options] [args]
      \nCommands:
        chat              Interactive REPL (default)
        ask <prompt>      One-shot query (reads stdin if piped)
        help              Show this help
      \nOptions:
    TEXT
    private_constant :USAGE

    def initialize(args, provider: "stub")
      @provider = provider
      @provider_options = {}
      @parser = OptionParser.new(USAGE) { |o| describe_options(o) }
      @args = @parser.parse!(args)
    end

    def run
      Signal.trap("INT") { exit 1 }
      dispatch(@args.shift || "chat")
    rescue StandardError, ScriptError => e
      Elelem.logger.warn("cli: #{e.message}\n#{e.backtrace.join("\n")}")
      abort "elelem: #{e.message}"
    end

    private

    def dispatch(command)
      COMMANDS.include?(command) ? send(command) : abort("Unknown command: #{command}")
    end

    def describe_options(parser)
      parser.on("-p", "--provider NAME", "Provider to use (default: #{@provider})") { |p| @provider = p }
      parser.on("--model NAME", "Model to use, passed to the provider") { |m| @provider_options[:model] = m }
      parser.on("--system-prompt TEXT", "Role text prepended to the system prompt") { |s| @system_prompt = s }
      parser.on("-h", "--help", "Show this help") { puts(parser) || exit }
    end

    def help = puts(@parser)

    def chat
      Elelem.start(provider: @provider, provider_options: @provider_options, system_prompt: @system_prompt)
    end

    def ask
      abort "Usage: elelem ask <prompt>" if @args.empty?

      piped = !$stdout.tty?
      reply = Elelem.ask(prompt_for_ask, provider: @provider, output: Output.new(stream: piped ? $stderr : $stdout),
                                         provider_options: @provider_options, system_prompt: @system_prompt)
      print_reply(reply, piped: piped)
    end

    def prompt_for_ask
      prompt = @args.join(" ")
      $stdin.stat.then { |s| s.pipe? || s.file? } ? "#{prompt}\n\n```\n#{$stdin.read}\n```" : prompt
    end

    def print_reply(reply, piped:)
      abort "elelem: no reply" if reply.to_s.strip.empty?
      Output.new.say(reply) if piped
    end
  end
end
