As a `user`, I `want slash commands available at any prompt`, so that `I can use /shell or other commands when the agent asks me a question`.

# SYNOPSIS

Enable slash command processing at every `Input#ask` call, not just the main REPL.

# DESCRIPTION

Currently, slash commands like `/shell` only run at the main agent
prompt: `Repl#command` dispatches them, but `Input#ask` only completes
them. When the agent asks a question (e.g., via the interview tool in
`elelem-tools`), typing `/shell` returns the text `/shell` as the
answer.

Example scenario:
1. Agent asks: "Should I commit this to git?"
2. User types `/shell`
3. User drops into shell, runs `git commit -m "fix bug"`, exits
4. Shell history/output is captured and returned as the answer
5. Agent knows the user committed the changes

Behavior:
- All `Input#ask` calls should process slash commands
- `/shell` captures command history and output from the subshell
- Result is returned as the "answer" to the prompt
- Other commands (`/help`, `/context`, etc.) work contextually

# SEE ALSO

* [ ] lib/elelem/input.rb:12 - `Input#ask`
* [ ] lib/elelem/input.rb:32 - `complete`, already completes slash commands at any prompt
* [ ] lib/elelem/commands.rb - Slash command registry
* [ ] lib/elelem/repl.rb:26 - `command`, REPL-only dispatch
* [ ] tools/lib/elelem/tools/shell.rb - `/shell`, adds the transcript to the conversation
* [ ] tools/lib/elelem/tools/interview.rb - asks with `agent.input.ask("> ")`

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] Slash commands recognized at any `Input#ask` prompt
* [ ] `/shell` drops user into interactive shell
* [ ] Shell session output/history captured on exit
* [ ] Captured output returned as the prompt answer
* [ ] `/help` shows available commands at any prompt
* [x] Tab completion works for slash commands at any prompt
* [ ] Regular text input still works normally
