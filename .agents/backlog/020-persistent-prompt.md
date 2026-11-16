As a `user`, I `want a persistent prompt showing current state`, so that `I always know the agent is ready for input`.

# SYNOPSIS

Always-visible prompt indicator showing mode and readiness state.

# DESCRIPTION

During long operations or after scrolling output, it can be unclear whether
the agent is ready for input. A persistent or always-visible prompt helps
orient the user.

Possible approaches:
1. Status line at bottom of terminal (like vim/tmux)
2. Clear prompt redraw after all output
3. Spinner/indicator that transitions to prompt when ready

Information to show:
- Current provider and model (core no longer has modes)
- Ready state (waiting for input vs. processing)
- Token usage or cost (optional)
- Current branch or project context (optional)

# SEE ALSO

* [ ] lib/elelem/repl.rb:10 - prompt is a plain `> ` passed to `Input#ask`
* [ ] lib/elelem/input.rb:26 - `read_line`, Reline prompt
* [ ] lib/elelem/builtins/terminal.rb:27 - `waiting`, the dots shown while processing
* [ ] lib/elelem/plugins/provider.rb - `/provider NAME [MODEL]` changes the provider mid-session
* [ ] .agents/backlog/031-terminal-styling.md - bold prompt, NO_COLOR
* [ ] ANSI escape sequences for cursor positioning

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] Prompt always visible or redrawn after output
* [ ] Current provider (and model, if set) displayed in or near the prompt
* [ ] Clear visual distinction between ready and processing states
* [ ] Prompt survives terminal resize
* [ ] Works correctly with pager integration (story 017)
* [ ] No visual glitches during rapid output
