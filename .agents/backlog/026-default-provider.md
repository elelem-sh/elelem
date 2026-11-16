As a `new user`, I `want to know which provider elelem is using`, so that `I am not confused by demo replies`.

# SYNOPSIS

Read a default provider from `ELELEM_PROVIDER`, and say when the demo provider is in use.

# DESCRIPTION

With no `-p`, elelem uses the `demo` provider. The default is hard-coded
in two places, `CLI#initialize(provider: "demo")` and
`Elelem.build(provider: "demo")`. The demo is a shell, not a model: it
runs what you type with `execute`, reads a file you name with `read`,
and replies with the exit status. A new user who types a question gets
a shell error back, with no hint why. The REPL banner only prints
`elelem vX.Y.Z`. The install hint (`gem install elelem-llama`) appears
only when no `execute` tool is loaded.

1. **Default**: `ELELEM_PROVIDER` sets the provider when `-p` is not
   given, as `elelem-server` and `elelem-evals` already do. `-p` still
   wins. An empty value counts as unset. `elelem help` shows the
   effective default.
2. **Notice**: when the demo provider is in use in `elelem chat`, print
   one line after the banner saying so, and how to pick a real one (for
   example `-p NAME`, `ELELEM_PROVIDER`, or `gem install elelem-llama`).
   `elelem ask` writes the notice to stderr, so a piped reply stays
   clean.
3. **Banner**: the REPL banner names the provider in use.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#12
* [ ] lib/elelem/cli.rb:19 - `initialize(args, provider: "demo")`
* [ ] lib/elelem/cli.rb:40 - `describe_options`, `-p` help shows the default
* [ ] lib/elelem.rb:39 - `Elelem.build(provider: "demo")`
* [ ] lib/elelem/repl.rb:10 - banner `elelem v#{VERSION}`
* [ ] lib/elelem/plugins/demo.rb:14 - `install_hint`
* [ ] llama/exe/elelem-llama - passes `provider: "llama"` to the CLI
* [ ] .agents/backlog/011-local-inference-implementation.md - local model on first run

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] `ELELEM_PROVIDER=NAME elelem` starts with provider `NAME`
* [ ] `-p` overrides `ELELEM_PROVIDER`
* [ ] An empty `ELELEM_PROVIDER` falls back to `demo`
* [ ] `elelem help` shows the effective default provider
* [ ] `elelem chat` with the demo provider prints one notice line that names how to choose a provider
* [ ] `elelem chat` with any other provider prints no notice
* [ ] `elelem ask` with the demo provider writes the notice to stderr, not stdout
* [ ] The REPL banner names the provider in use
* [ ] The README documents `ELELEM_PROVIDER`
