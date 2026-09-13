# frozen_string_literal: true

require "elelem"
require "io/console"
require "optparse"
require "reline"

module Elelem
  class CLI
    COMMANDS = %w[chat ask files help].freeze
    USAGE = <<~TEXT
      \nCommands:
        chat              Interactive REPL (default)
        ask <prompt>      One-shot query (reads stdin if piped)
        files             Output files as XML (no options)
        help              Show this help
      \nOptions:
    TEXT
    private_constant :USAGE

    def initialize(args, provider: "test")
      @provider = provider
      @args = parse(args)
    end

    def run
      command = @args.shift || "chat"
      abort "Unknown command: #{command}" unless COMMANDS.include?(command)
      send(command)
    end

    private

    def parse(args)
      @parser = OptionParser.new { |o| describe_options(o) }
      @parser.parse!(args)
    end

    def describe_options(parser)
      describe_usage(parser)
      parser.on("-p", "--provider NAME", "Provider to use (default: #{@provider})") { |p| @provider = p }
      parser.on("-h", "--help", "Show this help") { print_help_and_exit(parser) }
    end

    def print_help_and_exit(parser)
      puts parser
      exit
    end

    def describe_usage(parser)
      parser.banner = "Usage: #{File.basename($PROGRAM_NAME)} [command] [options] [args]"
      parser.separator USAGE
    end

    def help
      puts @parser
    end

    def chat
      Elelem.start(provider: @provider)
    rescue StandardError, ScriptError => e
      warn_and_abort(e)
    end

    def ask
      abort "Usage: elelem-chat ask <prompt>" if @args.empty?

      reply = Elelem.ask(prompt_for_ask, provider: @provider, output: output_for_ask)
      print_reply(reply, piped: piped?)
    rescue StandardError, ScriptError => e
      warn_and_abort(e)
    end

    def piped?
      !$stdout.tty?
    end

    def output_for_ask
      Elelem::Output.new(stream: piped? ? $stderr : $stdout)
    end

    def prompt_for_ask
      prompt = @args.join(" ")
      $stdin.stat.pipe? ? "#{prompt}\n\n```\n#{$stdin.read}\n```" : prompt
    end

    def print_reply(reply, piped:)
      abort "elelem: no reply" if reply.to_s.strip.empty?
      Elelem::Output.new.say(reply, as: :markdown) if piped
    end

    def warn_and_abort(error)
      Elelem.logger.warn("cli: #{error.message}\n#{error.backtrace.join("\n")}")
      abort "elelem: #{error.message}"
    end

    def files
      puts "<documents>"
      candidate_files.each_with_index { |line, i| print_document(line, i) }
      puts "</documents>"
    end

    def candidate_files
      $stdin.stat.pipe? ? $stdin.readlines : `git ls-files`.lines
    end

    def print_document(line, index)
      path = line.strip
      return if path.empty? || !File.file?(path)

      content = File.read(path)
      puts %(<document index="#{index + 1}"><source>#{path}</source>) +
           %(<document_content><![CDATA[#{content}]]></document_content></document>)
    end
  end
end
