# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:tools) do |agent|
    describe = lambda do |tool|
      parameters = tool.to_h.dig(:function, :parameters)
      lines = ["## #{tool.name}", "", tool.description, "", "### Parameters", ""]
      parameters[:properties].each do |param, spec|
        req = parameters[:required].include?(param.to_s) ? ", required" : ""
        desc = spec[:description] ? " - #{spec[:description]}" : ""
        lines << "- `#{param}` (#{spec[:type]}#{req})#{desc}"
      end
      lines << "" << "*aliases: #{tool.aliases.join(", ")}*" if tool.aliases.any?
      lines.join("\n")
    end

    completions = -> { agent.toolbox.tools.keys }
    agent.commands.register("tools", description: "List available tools", completions: completions) do |arg|
      tool = agent.toolbox.tools[arg] if arg && !arg.empty?
      if tool
        agent.output.say describe.call(tool), as: :markdown
      elsif arg && !arg.empty?
        agent.output.say "Unknown tool: #{arg}"
      else
        # values copies the list, so a plugin adding tools from a thread cannot break this loop.
        rows = agent.toolbox.tools.values.map { |t| "| #{t.name} | #{t.description.lines.first.chomp} |" }
        agent.output.say "| Tool | Description |\n|------|-------------|\n#{rows.join("\n")}", as: :markdown
      end
    end
  end
end
