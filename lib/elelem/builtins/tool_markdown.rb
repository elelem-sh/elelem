# frozen_string_literal: true

module Elelem
  module Builtins
    module ToolMarkdown
      def self.summary(tool)
        "| #{tool.name} | #{tool.description.lines.first.chomp} |"
      end

      def self.to_markdown(tool)
        parameters = tool.to_h[:function][:parameters]
        lines = ["## #{tool.name}", "", tool.description, "", "### Parameters", ""]
        parameters[:properties].each do |param, spec|
          req = parameters[:required].include?(param.to_s) ? ", required" : ""
          desc = spec[:description] ? " - #{spec[:description]}" : ""
          lines << "- `#{param}` (#{spec[:type]}#{req})#{desc}"
        end
        lines << "" << "*aliases: #{tool.aliases.join(", ")}*" if tool.aliases.any?
        lines.join("\n")
      end
    end
  end
end
