As a `user`, I `want to know about, turn off and limit session transcripts`, so that `old sessions do not pile up on disk without my knowledge`.

# SYNOPSIS

Document session transcripts, add an opt-out, and prune old ones.

# DESCRIPTION

`Builtins::Terminal`, the default output, appends every byte it prints
to a transcript file, `<started_at>-<pid>.transcript`, in
`$XDG_STATE_HOME/elelem/sessions/` (default
`~/.local/state/elelem/sessions/`). The directory is mode 0700 and the
files 0600. One file is written per session, for `elelem chat` and for
`elelem ask` at a terminal, and none is ever deleted. Nothing tells the
user this happens.

The log next to it is bounded (`OLD_LOGS_KEPT = 3`,
`LOG_SIZE_LIMIT = 1MB`); the transcripts are not.

1. **Document** where transcripts go, what they contain (everything
   shown on screen, including file contents and command output), and
   their permissions, in the README and on elelem.sh.
2. **Opt out** with `ELELEM_TRANSCRIPTS=0`: no file and no `sessions`
   directory are created.
3. **Prune** at start: keep the newest N transcripts (for example 50)
   or those newer than D days, and delete the rest. Make the limit
   configurable with an environment variable, and `0` keep everything.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#22
* [ ] lib/elelem/builtins/terminal.rb:93 - `write`, appends every write to the transcript
* [ ] lib/elelem/builtins/terminal.rb:99 - `transcript_path`
* [ ] lib/elelem/builtins/terminal.rb:107 - `sessions_dir`, creates it with mode 0700
* [ ] lib/elelem.rb:35 - `OLD_LOGS_KEPT` and `LOG_SIZE_LIMIT`, how the log is bounded
* [ ] lib/elelem.rb:43 - `state_dir`
* [ ] .agents/backlog/012-xdg-base-directory-support.md - where state lives

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] The README says where transcripts are written and what they contain
* [ ] With `ELELEM_TRANSCRIPTS=0`, a session writes no transcript and creates no `sessions` directory
* [ ] Without it, transcripts are written as today, with the same permissions
* [ ] At start, transcripts beyond the retention limit are deleted, oldest first
* [ ] The retention limit can be changed, and set to keep everything
* [ ] Pruning never deletes the current session's transcript
* [ ] Pruning failures (for example a read-only directory) are logged and do not stop elelem
