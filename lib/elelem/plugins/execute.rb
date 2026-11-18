# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:execute) do |agent|
    shell = case Elelem::Builtins.shell
            when :bash then "bash"
            when :sh then "sh; install bash for the git, glob, grep, list and verify tools"
            else "cmd.exe; install Git for Windows for bash and the git, glob, grep, list and verify tools"
            end
    agent.toolbox.add("execute",
                      description: "Run shell command (supports pipes and redirections) in #{shell}",
                      params: { command: { type: "string" } },
                      required: ["command"],
                      aliases: ["bash", "sh", "exec", "execute<|channel|>"]) do |a|
      timeout = Integer(ENV.fetch("ELELEM_CMD_TIMEOUT", "0"))
      timeout = nil unless timeout.positive?
      cmd, *args = Elelem::Builtins.shell_command(a["command"])
      result = Elelem::Builtins.sh(cmd, args: args, timeout: timeout) { |x| agent.output.print(x) }
      result[:exit_status].zero? ? result : result.merge(error: "exit #{result[:exit_status]}")
    end

    agent.toolbox.after("execute") do |args, result|
      next if result[:exit_status].zero?

      agent.output.doing("execute", args, state: "x")
    end
  end
end
