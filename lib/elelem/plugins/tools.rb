# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:tools) do |agent|
    completions = -> { agent.toolbox.tools.keys }

    agent.commands.register("tools", description: "List available tools", completions: completions) do |arg|
      if arg && !arg.empty?
        tool = agent.toolbox.tools[arg]
        unless tool
          agent.output.say "Unknown tool: #{arg}"
          next
        end

        agent.output.say Elelem::Builtins::ToolMarkdown.to_markdown(tool), as: :markdown
      else
        rows = agent.toolbox.tools.each_value.map { |tool| Elelem::Builtins::ToolMarkdown.summary(tool) }

        md = String.new("| Tool | Description |\n")
        md << "|------|-------------|\n"
        md << rows.join("\n")

        agent.output.say md, as: :markdown
      end
    end
  end
end
