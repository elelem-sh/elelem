# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:execute) do |agent|
    agent.toolbox.add("execute",
                      description: "Run shell command (supports pipes and redirections)",
                      params: { command: { type: "string" } },
                      required: ["command"],
                      aliases: ["bash", "sh", "exec", "execute<|channel|>"]) do |a|
      # The timeout kills the whole process group, so `npm start &` cannot hang the session.
      value = ENV.fetch("ELELEM_CMD_TIMEOUT", "")
      timeout = value.empty? ? 300 : Integer(value)
      timeout = nil if timeout.zero?
      result = Elelem::Builtins.sh("bash", args: ["-c", a["command"]], timeout: timeout) { |x| agent.output.print(x) }
      result.merge(ok: result[:exit_status].zero?)
    end

    agent.toolbox.after("execute") do |args, result|
      next if result[:exit_status].zero?

      agent.output.doing("execute", args, state: "x")
    end
  end
end
