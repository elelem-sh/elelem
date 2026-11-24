# frozen_string_literal: true

require "elelem"
require "optparse"

module Elelem
  class CLI
    USAGE = "Usage: #{File.basename($PROGRAM_NAME)} [options] [prompt]\n\nOptions:".freeze
    private_constant :USAGE

    def initialize(args, provider: "demo")
      @provider = provider
      @provider_options = {}
      @parser = OptionParser.new(USAGE) { |o| describe_options(o) }
      @args = @parser.parse!(args)
    end

    def run
      Signal.trap("INT") { exit 1 }
      @args.empty? && $stdin.tty? ? chat : ask
    rescue StandardError, ScriptError => e
      Elelem.logger.warn("cli: #{e.message}\n#{e.backtrace.join("\n")}")
      abort "elelem: #{e.message}"
    end

    private

    def describe_options(parser)
      parser.on("-p", "--provider NAME", "Provider to use (default: #{@provider})") { |p| @provider = p }
      parser.on("--model NAME", "Model to use, passed to the provider") { |m| @provider_options[:model] = m }
      parser.on("--system-prompt TEXT", "Role text prepended to the system prompt") { |s| @system_prompt = s }
      parser.on("-h", "--help", "Show this help") { puts(parser) || exit }
    end

    def chat
      Elelem.start(provider: @provider, provider_options: @provider_options, system_prompt: @system_prompt)
    end

    def ask
      prompt = prompt_for_ask
      abort @parser.to_s if prompt.empty?

      piped = !$stdout.tty?
      reply = Elelem.ask(prompt, provider: @provider, output: progress_output(piped),
                                 provider_options: @provider_options, system_prompt: @system_prompt)
      print_reply(reply, piped: piped)
    end

    def progress_output(piped)
      Output.new(stream: $stderr) if piped
    end

    def prompt_for_ask
      prompt = @args.join(" ")
      piped = stdin_piped? ? $stdin.read : ""
      piped.empty? ? prompt : "#{prompt}\n\n```\n#{piped}\n```"
    end

    def stdin_piped? = $stdin.stat.then { |stat| stat.pipe? || stat.file? }

    def print_reply(reply, piped:)
      abort "elelem: no reply" if reply.to_s.strip.empty?
      Output.new.say(reply) if piped
    end
  end
end
