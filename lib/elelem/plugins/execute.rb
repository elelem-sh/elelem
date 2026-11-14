# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:execute) do |agent|
    agent.toolbox.add("execute",
                      description: "Run shell command (supports pipes and redirections)",
                      params: { command: { type: "string" } },
                      required: ["command"],
                      aliases: ["bash", "sh", "exec", "execute<|channel|>"]) do |a|
      Elelem::Builtins.sh("bash", args: ["-c", a["command"]], timeout: Elelem::Builtins.command_timeout) { |x| agent.output.print(x) }
    end

    agent.toolbox.after("execute") do |args, result|
      next if result[:exit_status].zero?

      agent.output.doing("execute", args, state: "x")
    end
  end
end
