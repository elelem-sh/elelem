As a `user`, I `want the reply to appear as the model writes it`, so that `a long reply does not look like a hang`.

# SYNOPSIS

Write `saying` deltas to the output as they arrive, not once at the end.

# DESCRIPTION

Every provider streams, but the agent buffers the reply. `Agent#stream`
collects every event of a fetch into an array and only shows
`thinking` events as they arrive. `Agent#fetch` then joins the `saying`
text and prints it in one `output.say(content, as: :markdown)` call
after the stream ends. Until then the user sees only the waiting dots,
or nothing, for the whole reply.

The buffering exists because `Terminal#markdown` renders the reply
through `glow`, which needs the whole text. Streaming changes that:

1. Print `saying` deltas as they arrive, through a new `Output` method
   (for example `Output#saying`), the way `thinking` already works.
2. Choose how markdown is handled once text is streamed: print raw text
   while streaming, then nothing more; or stream raw text and re-render
   with `glow` at the end only when the output is a terminal; or render
   complete blocks (paragraphs, fences) as they close. Pick the
   simplest that does not print the reply twice in the scrollback.
3. `Agent#turn` still returns the full reply text, so `elelem ask` and
   the conversation are unchanged.
4. `NullOutput` and the piped `ask` path keep working: a piped reply
   prints once, as plain text.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#10
* [ ] lib/elelem/agent.rb:38 - `fetch`, joins `saying` text and prints it after the stream
* [ ] lib/elelem/agent.rb:46 - `stream`, collects events, shows only thinking live
* [ ] lib/elelem/agent.rb:54 - `show_thinking`
* [ ] lib/elelem/output.rb:21 - `Output#thinking`, the model for a streaming method
* [ ] lib/elelem/builtins/terminal.rb:46 - `markdown`, renders the whole reply with `glow`
* [ ] lib/elelem/cli.rb:71 - `print_reply`, prints a piped `ask` reply
* [ ] .agents/backlog/017-pager-integration.md - paging depends on when text is printed

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] In `elelem chat`, reply text appears while the provider is still streaming
* [ ] The reply appears once in the terminal scrollback, not twice
* [ ] Thinking text still streams, and is visually distinct from the reply
* [ ] `Agent#turn` returns the same full reply text as before
* [ ] `elelem ask "..." | cat` prints the reply once, as plain text
* [ ] A provider that sends the whole reply as one `saying` event still works
* [ ] Specs cover a reply split across several `saying` events
