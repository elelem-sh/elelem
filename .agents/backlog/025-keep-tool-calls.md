As a `user`, I `want the model to remember what it read and ran in earlier turns`, so that `it does not have to read the same files again`.

# SYNOPSIS

Optionally keep tool calls and results across turns, or keep a compact summary of them.

# DESCRIPTION

After a turn, the conversation keeps only the user prompt and the final
assistant reply. Tool calls and their results live in the turn's local
`ctx` array in `Agent#run_until_done` and are dropped when the turn
ends. `Conversation#add` only accepts `user` and `assistant` roles, and
its spec says so on purpose ("tool calls stay in the turn").

This is deliberate: it keeps the context small, and it is now
documented. The cost is that in the next turn the model cannot refer to
a file it read or a command it ran, so it reads or runs them again, or
guesses.

Add a way to keep that work, off by default:

1. **Keep**: an option (for example `--keep-tools` on the CLI and a
   `keep_tools:` keyword on `Elelem.build`) that stores the assistant
   tool-call messages and tool results in the conversation, in order,
   so the next turn sends them to the provider.
2. **Compact**: instead of full results, store a short line per call
   (tool name, arguments, ok or error, size), so the model knows what it
   did without the full output.

Pick one, or both behind one option with two values. Either way:

* A failed turn still leaves the conversation as it was.
* `/context` lists the kept entries.
* `/clear` removes them.
* Provider gems must accept `tool` messages and assistant messages with
  `tool_calls` in the history, as they already do within a turn.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#11
* [ ] lib/elelem/agent.rb:15 - `turn`, adds only the prompt and the reply
* [ ] lib/elelem/agent.rb:25 - `run_until_done`, holds tool calls in `ctx`
* [ ] lib/elelem/conversation.rb:5 - `ROLES = %w[user assistant]`
* [ ] lib/elelem/conversation.rb:13 - `add`, rejects other roles
* [ ] spec/elelem/conversation_spec.rb:25 - "rejects tool role, since tool calls stay in the turn"
* [ ] lib/elelem/plugins/context.rb - `/context`
* [ ] tools/lib/elelem/tools/compact.rb - `/compact`, summarizes the whole conversation
* [ ] .agents/backlog/021-context-editing.md - pruning kept entries by hand

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] By default, behavior is unchanged: only prompt and reply are kept
* [ ] With the option on, the next turn's request includes the earlier tool calls and results
* [ ] With compaction, each earlier call is one short entry, not its full output
* [ ] The option is available from the CLI and from `Elelem.build`
* [ ] A failed turn leaves the conversation as it was, with the option on or off
* [ ] `/context` shows the kept entries, and `/clear` removes them
* [ ] The default and the option are documented in the README and on elelem.sh
