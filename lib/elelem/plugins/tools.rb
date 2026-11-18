# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:tools) do |agent|
    completions = -> { agent.toolbox.tools.keys }
    agent.commands.register("tools", description: "List available tools", completions: completions) do |arg|
      if arg.to_s.empty?
        rows = agent.toolbox.tools.values.map { |t| "| #{t.name} | #{t.description.lines.first.chomp} |" }
        agent.output.say "| Tool | Description |\n|------|-------------|\n#{rows.join("\n")}", as: :markdown
      elsif (tool = agent.toolbox.tool_for(arg))
        agent.output.say JSON.pretty_generate(tool.to_h[:function].merge(aliases: tool.aliases)), as: :markdown
      else
        agent.output.say "Unknown tool: #{arg}"
      end
    end
  end
end
