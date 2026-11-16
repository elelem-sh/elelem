As a `Linux user`, I `want elelem to respect the XDG Base Directory variables`, so that `its files are kept where I expect them`.

# SYNOPSIS

Decide whether user config follows `XDG_CONFIG_HOME`; state already follows `XDG_STATE_HOME`.

# DESCRIPTION

Part of this has shipped. `Elelem.state_dir` is
`$XDG_STATE_HOME/elelem`, or `~/.local/state/elelem` when the variable
is unset. The log (`elelem.log`) and the session transcripts
(`sessions/*.transcript`) are written there (5a1cb06, 8f81f14).

The rest of the old story no longer applies to core: `~/.elelem` is
gone (renamed to `~/.agents` in 0.11.0), and permissions, MCP config,
OAuth tokens and models moved out to plugin gems.

What remains is user config. Core reads it from fixed paths:

* `~/.agents/plugins/*.rb` and `.agents/plugins/*.rb` (plugins)
* `~/.agents/AGENTS.md` and the nearest `AGENTS.md` up the tree
  (system prompt)

`~/.agents` is shared with other agent tools, so moving it under
`$XDG_CONFIG_HOME/elelem` would split it from them. Decide one of:

1. Keep `~/.agents` and document why it does not follow XDG.
2. Also look in `$XDG_CONFIG_HOME/agents` (default `~/.config/agents`),
   with `~/.agents` still read, and a fixed order between them.

Plugin gems that keep their own files (`elelem-llama` models in
`~/.agents/models`, `elelem-mcp` logs and tokens) should follow the
same decision; caches such as downloaded models belong under
`XDG_CACHE_HOME` if option 2 is chosen.

# SEE ALSO

* [ ] lib/elelem.rb:43 - `state_dir`, uses `XDG_STATE_HOME`
* [ ] lib/elelem/builtins/terminal.rb:107 - `sessions_dir` under `state_dir`
* [ ] lib/elelem/plugins.rb:5 - `LOAD_PATHS`, `~/.agents/plugins` and `.agents/plugins`
* [ ] lib/elelem/system_prompt.rb:6 - `USER_AGENTS_MD`, `~/.agents/AGENTS.md`
* [ ] llama/lib/elelem/llama/model_resolver.rb - models in `~/.agents/models`
* [ ] https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [x] When `XDG_STATE_HOME` is set, the log and transcripts go to `$XDG_STATE_HOME/elelem/`
* [x] When `XDG_STATE_HOME` is unset, they go to `~/.local/state/elelem/`
* [ ] The choice between option 1 and option 2 is recorded in this story
* [ ] The README and elelem.sh state where elelem reads config and writes state
* [ ] If option 2: with `XDG_CONFIG_HOME` set, plugins and `AGENTS.md` load from `$XDG_CONFIG_HOME/agents/`
* [ ] If option 2: with it unset, they load from `~/.config/agents/`
* [ ] If option 2: `~/.agents` still loads, and the order between the two is documented and tested
* [ ] Project-local `.agents/plugins` still loads after user plugins, so it can override them
