As a `user`, I `want to interrupt the agent with CTRL+C`, so that `I can stop and redirect when the agent goes off track`.

# SYNOPSIS

CTRL+C cancels the current turn and returns to the prompt; a second CTRL+C exits.

# DESCRIPTION

When the agent is generating a response or executing tools, the user
may realize it's going in the wrong direction. Today CTRL+C ends the
whole session: `CLI#run` installs `Signal.trap("INT") { exit 1 }`, so
the first press exits with status 1 and the conversation is lost.

What already works:

* A turn that raises leaves the conversation as it was (21a9dae):
  `Agent#turn` only adds the prompt and reply after `run_until_done`
  returns.
* A running `execute` command is stopped with the process (c068920):
  `Command#stop_on_interrupt` re-raises `Interrupt` and `SystemExit`,
  and kills the process group when `ELELEM_CMD_TIMEOUT` is set.

Desired behavior:

1. User presses CTRL+C during a reply or a tool call
2. Generation or the tool stops at once
3. The partial turn is discarded (not added to context)
4. User returns to a fresh prompt, with a short note that the turn was
   interrupted
5. A second CTRL+C within a short window exits

At an idle prompt, CTRL+C still exits, as it does today. `elelem ask`
keeps exiting on the first CTRL+C, since there is no prompt to return
to.

Commands run without a timeout share elelem's process group, so the
terminal sends them SIGINT too; commands run with a timeout get their
own group and must be killed by elelem. Both cases must leave no
orphaned processes.

This pairs well with context editing (story 021): after interrupting,
the user may want to prune context before continuing.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#17
* [ ] lib/elelem/cli.rb:27 - `Signal.trap("INT") { exit 1 }`
* [ ] lib/elelem/repl.rb:18 - `dispatch_line`, rescues `StandardError` but not `Interrupt`
* [ ] lib/elelem/agent.rb:15 - `turn`, adds to the conversation only after the turn completes
* [ ] lib/elelem/builtins/command.rb:25 - `stop_on_interrupt`
* [ ] lib/elelem/builtins/command.rb:21 - `spawn_options`, own process group only with a timeout
* [ ] llama/exe/elelem-llama - installs the same `exit 1` trap
* [ ] .agents/backlog/021-context-editing.md - Related feature

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] In `elelem chat`, CTRL+C during a reply stops it and returns to the prompt
* [ ] CTRL+C during a tool call stops the tool and returns to the prompt
* [x] A turn that fails is not added to conversation context
* [ ] An interrupted turn is not added to conversation context
* [ ] A note says the turn was interrupted
* [ ] A second CTRL+C within a short window exits elelem
* [x] CTRL+C at an idle prompt exits
* [ ] No orphaned processes remain after an interrupt, with or without `ELELEM_CMD_TIMEOUT`
* [ ] Multiple rapid CTRL+C presses are handled without a backtrace
* [ ] `elelem ask` still exits on the first CTRL+C
