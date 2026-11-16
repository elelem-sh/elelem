As a `user of a weaker model`, I `want the system prompt to say where the agent is and what the project contains`, so that `the model does not guess the language or skip reading the code`.

# SYNOPSIS

Add a few lines of environment context (cwd, git, top-level files, OS, shell) to the default system prompt.

# DESCRIPTION

The default template, `lib/elelem/prompts/default.erb`, is
"You are a terminal coding agent." plus any `AGENTS.md` (global and the
nearest up the tree). Nothing tells the model where it is or what the
project holds.

In a test on a small Ruby project with a failing minitest test and no
`AGENTS.md`, gpt-oss-120b listed the files, read the code and fixed the
bug. Llama 3.3 70B never read a file: it assumed Python, ran `pip
install pytest`, wrote a fake test and reported success. With a
two-line `AGENTS.md` it ran the right test command but still did not
read the code.

Add a short environment block to the default template:

* the current working directory;
* whether it is a git repo, and the top-level entries (or a capped
  sample of `git ls-files`);
* the OS and the user's shell.

Keep it to a few lines and bounded in size, so the core stays small and
`AGENTS.md` stays the place for project rules. It is rendered on each
turn, like `AGENTS.md`, so it follows `cd` within a session.

A custom `template:` or `--system-prompt` still works: the block is part
of the default template only, so a custom template can leave it out.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#44
* [ ] lib/elelem/prompts/default.erb - the default template
* [ ] lib/elelem/system_prompt.rb:14 - `render`, ERB with the `SystemPrompt` binding
* [ ] lib/elelem/system_prompt.rb:20 - `agents_md`, the model for a helper the template calls
* [ ] lib/elelem/conversation.rb:22 - `to_a`, renders the system prompt each turn
* [ ] spec/elelem/system_prompt_spec.rb

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] The default system prompt includes the working directory
* [ ] In a git repo, it says so and lists top-level entries, capped at a fixed count
* [ ] Outside a git repo, it lists top-level entries without error
* [ ] It names the OS and the shell
* [ ] The block adds no more than a fixed number of lines, whatever the repo size
* [ ] `AGENTS.md` content still follows the block
* [ ] A custom `template:` without the helper renders no environment block
* [ ] Specs cover a git repo, a plain directory, and a large repo
