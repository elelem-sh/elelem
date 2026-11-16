As a `user`, I `want to view, delete, and edit context entries`, so that `I can manually prune or summarize the conversation`.

# SYNOPSIS

`/context` command to list, delete, and edit conversation entries.

# DESCRIPTION

As conversations grow, the context can become bloated with irrelevant
entries. The user should be able to:

1. **View** context as a numbered list with role and preview (shipped:
   `/context`, `/context N`, `/context json`)
2. **Delete** entries interactively or by number
3. **Edit** a single entry in `$EDITOR`

Example session:
```
> /context
1. [system] You are a developer... (245 tokens)
2. [user] Fix the login bug
3. [assistant] I'll look at auth.rb... (89 tokens)
4. [assistant] auth.rb checks the token before... (1200 tokens)
5. [assistant] The issue is on line 42... (156 tokens)

> /context delete
  [ ] 1. [system] You are a developer...
  [x] 4. [assistant] auth.rb checks the token before...
  
Deleted 1 entry.

> /context edit 3
# Opens entry 3 in $EDITOR, saves changes back to context
```

Notes on the current code:

* The conversation holds only `user` and `assistant` messages. Tool
  calls and results stay inside the turn (see story 025).
* Entry 1 is the system prompt. It is rendered on each turn from the
  template and `AGENTS.md`, not stored, so it cannot be deleted or
  edited from the list.
* `Conversation` has `add`, `last` and `clear!` only; delete and
  replace by index are new.

# SEE ALSO

* [ ] lib/elelem/conversation.rb - Context storage
* [ ] lib/elelem/plugins/context.rb - `/context`, `/context N`, `/context json`
* [ ] lib/elelem/commands.rb - Slash command registry
* [ ] .agents/backlog/009-enhanced-interview-tool.md - Multi-select UI
* [ ] .agents/backlog/019-interruptibility.md - Related workflow
* [ ] .agents/backlog/025-keep-tool-calls.md - what the conversation keeps

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [x] `/context` shows numbered list with role and preview
* [ ] Each entry shows approximate token count
* [ ] `/context delete` opens interactive multi-select
* [ ] `/context delete 3,4,5` deletes by number
* [ ] `/context edit N` opens entry N in `$EDITOR`
* [ ] Edited content replaces original entry
* [ ] Empty edit (delete all content) removes the entry
* [ ] System prompt (entry 1) protected from deletion
* [ ] Changes reflected immediately in conversation
