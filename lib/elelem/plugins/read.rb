# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:read) do |agent|
    agent.toolbox.add("read",
                      description: "Read file",
                      params: { path: { type: "string" } },
                      required: ["path"],
                      aliases: ["open"]) do |a|
      path = Pathname.new(a["path"]).expand_path
      next { error: "not found" } unless path.exist?

      content = path.binread
      next { error: "binary file (#{content.bytesize} bytes)" } if content.include?("\0")

      content = content.force_encoding(Encoding::UTF_8).scrub

      { content: Elelem::Builtins.truncate(content), path: a["path"] }
    end

    agent.toolbox.after("read") do |_, result|
      if result[:error]
        agent.output.say "  ! #{result[:error]}"
      else
        agent.output.display_file(result[:path], fallback: result[:content])
      end
    end
  end
end
