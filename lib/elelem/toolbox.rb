# frozen_string_literal: true

module Elelem
  class Toolbox
    attr_reader :tools

    def initialize
      @tools = {}
      @aliases = {}
      @hooks = %i[before after].to_h { |type| [type, Hash.new { |hooks, name| hooks[name] = [] }] }
    end

    def clear!
      [@tools, @aliases, *@hooks.values].each(&:clear)
    end

    def add(name, description:, params: {}, required: [], aliases: [], &handler)
      aliases.each { |a| @aliases[a] = name }
      @tools[name] = Tool.new(name, description:, params:, required:, aliases:, &handler)
    end

    def before(tool_name = :*, &) = hook(:before, tool_name, &)
    def after(tool_name = :*, &) = hook(:after, tool_name, &)

    def tool_for(name)
      tools[name] || tools[@aliases[name]]
    end

    def run(name, args)
      tool = tool_for(name)
      invalid(name, tool, args) || to_result(dispatch(tool, args))
    rescue StandardError, ScriptError => e
      Elelem.logger.warn("toolbox: #{e.message}\n#{e.backtrace.join("\n")}")
      Result.failure(error: e.message, name: name, args: args)
    end

    def to_a
      tools.values.map(&:to_h)
    end

    private

    def hook(type, name, &block) = @hooks[type][name] << block

    def invalid(name, tool, args)
      errors = tool ? tool.validate(args) : ["unknown tool: #{name.inspect}. Available: #{tools.keys.join(", ")}."]
      Result.failure(error: errors.join(", ")) if errors.any?
    end

    def to_result(result)
      result[:error] ? Result.failure(result) : Result.success(result)
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
