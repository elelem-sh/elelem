# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:write) do |agent|
    agent.toolbox.add("write",
                      description: "Write file",
                      params: { path: { type: "string" }, content: { type: "string" } },
                      required: %w[path content],
                      aliases: ["write<|channel|>"]) do |a|
      path = Pathname.new(a["path"]).expand_path
      FileUtils.mkdir_p(path.dirname)
      { bytes: path.write(a["content"]), path: a["path"] }
    end

    agent.toolbox.before("write") do |args|
      path = Pathname.new(args["path"]).expand_path
      next unless path.exist? && agent.input.interactive?

      Tempfile.create(["elelem", File.extname(path)]) do |t|
        t.write(args["content"])
        t.flush
        diff, = Open3.capture2("diff", "--color=always", "-u", path.to_s, t.path)
        agent.output.print(diff)
      end
    rescue Errno::ENOENT
      nil # no diff installed
    end

    agent.toolbox.after("write") do |_, result|
      agent.output.display_file(result[:path], fallback: "  -> #{result[:path]}")
      # The model sees the checks in the write's own result.
      if agent.toolbox.tools.key?("verify")
        result[:verify] = agent.toolbox.run("verify", { "path" => result[:path] }).to_h
      end
    end
  end
end
