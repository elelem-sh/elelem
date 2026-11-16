As a `user`, I `want styling only on a terminal, and none with NO_COLOR`, so that `piped output and logs are free of escape codes`.

# SYNOPSIS

Route all escape codes through one helper that honors NO_COLOR, TERM=dumb and non-TTY output; use weight, not color.

# DESCRIPTION

`Output#thinking` writes `\e[2;3m...\e[0m` and `Output#doing` writes
`\e[36m...\e[0m` whatever the stream is. When output goes to a pipe or
a file, for example the progress `elelem ask` writes to stderr when
stdout is piped, CI logs, or `| less`, the text fills with escape
codes. `NO_COLOR` is ignored. `Builtins::Terminal` (now in core) adds
its own: `glow -s dark` for replies, `bat` for files, and
`diff --color=always` in the write hook.

The brand rule (https://elelem.sh/brand/) is: in the terminal, elelem
uses weight, not color. It uses only the 16 ANSI colors, never sets the
cursor, and only styles output on a terminal.

1. **Color check** on `Output`:

   ```ruby
   def color?
     @stream.tty? && ENV["NO_COLOR"].to_s.empty? && ENV["TERM"] != "dumb"
   end
   ```

   Optionally honor `FORCE_COLOR` as an override. Route every escape
   code through one helper, for example `style(text, :bold, :dim)`,
   that returns plain text when `color?` is false.
2. **Prompt**: bold `> ` when color is on, plain otherwise. Reline needs
   the escape codes marked zero-width (`\1...\2`) to measure the prompt.
   Test long lines that wrap.
3. **Tool calls**: bold tool name and dim arguments, instead of cyan.
4. **Thinking**: dim italic, as now.
5. **Errors**: the error prefix in ANSI red (31), elelem's one accent.
6. **External tools**: with color off, do not ask `glow`, `bat` or
   `diff` for color (`diff --color=never`, `bat --color=never`, plain
   text instead of `glow`).
7. **Do not** set the cursor's color or shape (OSC 12, DECSCUSR).

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#42
* [ ] lib/elelem/output.rb:22 - `thinking`, `\e[2;3m`
* [ ] lib/elelem/output.rb:26 - `doing`, `\e[36m`
* [ ] lib/elelem/output.rb:37 - `render`, the `:error` prefix
* [ ] lib/elelem/builtins/terminal.rb:38 - `render`, error as `x text`
* [ ] lib/elelem/builtins/terminal.rb:46 - `markdown`, `glow -s dark`
* [ ] lib/elelem/builtins/terminal.rb:32 - `display_file`, `bat`
* [ ] lib/elelem/plugins/write.rb:22 - `diff --color=always`
* [ ] lib/elelem/repl.rb:10 - prompt `> `
* [ ] lib/elelem/cli.rb:62 - `progress_output`, plain `Output` on stderr when piped
* [ ] https://no-color.org/

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] `elelem ask "hi" 2>&1 | cat` contains no escape codes
* [ ] `NO_COLOR=1 elelem chat` prints no escape codes
* [ ] `TERM=dumb elelem chat` prints no escape codes
* [ ] On a terminal, the prompt is bold, tool names are bold, arguments and thinking are dim
* [ ] On a terminal, the error prefix is red, and no other hue appears
* [ ] A long input line at the bold prompt wraps and edits correctly
* [ ] All escape codes in core go through one helper
* [ ] elelem never sets the cursor color or shape
