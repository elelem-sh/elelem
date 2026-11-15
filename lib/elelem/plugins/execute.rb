# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:execute) do |agent|
    agent.toolbox.add("execute",
                      description: "Run shell command (supports pipes and redirections)",
                      params: { command: { type: "string" } },
                      required: ["command"],
                      aliases: ["bash", "sh", "exec", "execute<|channel|>"]) do |a|
      timeout = Integer(ENV.fetch("ELELEM_CMD_TIMEOUT", "0"))
      timeout = nil unless timeout.positive?
      result = Elelem::Builtins.sh("bash", args: ["-c", a["command"]], timeout: timeout) { |x| agent.output.print(x) }
      result[:exit_status].zero? ? result : result.merge(error: "exit #{result[:exit_status]}")
    end

    agent.toolbox.after("execute") do |args, result|
      next if result[:exit_status].zero?

      agent.output.doing("execute", args, state: "x")
    end
  end
end
