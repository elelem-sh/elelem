# frozen_string_literal: true

module Elelem
  class Toolbox
    attr_reader :tools

    def initialize
      @tools = {}
      @aliases = {}
      @hooks = { before: Hash.new { |h, k| h[k] = [] }, after: Hash.new { |h, k| h[k] = [] } }
    end

    def clear!
      [@tools, @aliases, @hooks[:before], @hooks[:after]].each(&:clear)
    end

    def add(name, description:, params: {}, required: [], aliases: [], &handler)
      aliases.each { |a| @aliases[a] = name }
      @tools[name] = Tool.new(name, description:, params:, required:, aliases:, &handler)
    end

    def before(tool_name = :*, &block)
      @hooks[:before][tool_name] << block
    end

    def after(tool_name = :*, &block)
      @hooks[:after][tool_name] << block
    end

    # The tool by name, else by alias, so a real tool named like an alias wins.
    def tool_for(name)
      tools[name] || tools[@aliases[name]]
    end

    def run(name, args)
      tool = tool_for(name)
      invalid(name, tool, args) || to_result(dispatch(tool, args))
    rescue StandardError, ScriptError => e
      Elelem.logger.debug("toolbox: #{e.message}\n#{e.backtrace.join("\n")}")
      Result.failure(error: e.message, name: name, args: args)
    end

    def to_a
      tools.values.map(&:to_h)
    end

    private

    def invalid(name, tool, args)
      errors = tool ? tool.validate(args) : ["unknown tool: #{name.inspect}. Available: #{tools.keys.join(", ")}."]
      Result.failure(error: errors.join(", ")) if errors.any?
    end

    # A tool fails by returning error:, or ok: false (as execute does for a
    # non-zero exit).
    def to_result(result)
      result[:error] || result[:ok] == false ? Result.failure(result) : Result.success(result)
    end

    def dispatch(tool, args)
      run_hooks(:before, tool, args)
      tool.call(args).tap { |result| run_hooks(:after, tool, args, result) }
    end

    def run_hooks(type, tool, *)
      @hooks[type][:*].each { |h| h.call(*, tool_name: tool.name) }
      @hooks[type][tool.name].each { |h| h.call(*) }
    end
  end
end
