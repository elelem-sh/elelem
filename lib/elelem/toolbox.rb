# frozen_string_literal: true

module Elelem
  class Toolbox
    attr_reader :tools, :hooks, :aliases

    def initialize
      @tools = {}
      @aliases = {}
      @hooks = { before: Hash.new { |h, k| h[k] = [] }, after: Hash.new { |h, k| h[k] = [] } }
    end

    def clear!
      @tools.clear
      @aliases.clear
      @hooks[:before].clear
      @hooks[:after].clear
    end

    def add(name, description:, params: {}, required: [], aliases: [], &handler)
      schema = Schema.new(params: params, required: required)
      tool = Tool.new(name, description: description, schema: schema, aliases: aliases, &handler)
      @tools[name] = tool
      tool.aliases.each { |a| @aliases[a] = name }
    end

    def before(tool_name = :*, &block)
      @hooks[:before][tool_name] << block
    end

    def after(tool_name = :*, &block)
      @hooks[:after][tool_name] << block
    end

    def tool_for(name)
      tools.fetch(@aliases.fetch(name, name)) { NullTool.new(name, available: tools.keys) }
    end

    def run(name, args)
      tool = tool_for(name)
      invalid(tool, args) || to_result(dispatch(tool, args))
    rescue StandardError, ScriptError => e
      failure(name, args, e)
    end

    def to_a
      tools.values.map(&:to_h)
    end

    private

    def invalid(tool, args)
      errors = tool.validate(args)
      Result.failure(error: errors.join(", ")) if errors.any?
    end

    def to_result(result)
      result[:error] ? Result.failure(result) : Result.success(result)
    end

    def failure(name, args, error)
      Elelem.logger.warn("toolbox: #{error.message}\n#{error.backtrace.join("\n")}")
      Result.failure(error: error.message, name: name, args: args)
    end

    def dispatch(tool, args)
      run_before_hooks(tool, args)
      result = tool.call(args)
      run_after_hooks(tool, args, result)
      result
    end

    def run_before_hooks(tool, args)
      @hooks[:before][:*].each { |h| h.call(args, tool_name: tool.name) }
      @hooks[:before][tool.name].each { |h| h.call(args) }
    end

    def run_after_hooks(tool, args, result)
      @hooks[:after][:*].each { |h| h.call(args, result, tool_name: tool.name) }
      @hooks[:after][tool.name].each { |h| h.call(args, result) }
    end
  end
end
