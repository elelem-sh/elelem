As a `user`, I `want installed plugin gems to load without a hand-written loader file`, so that `installing a plugin gem is enough to use it`.

# SYNOPSIS

Load installed non-provider plugin gems (tools, mcp, skills, ...) without `~/.agents/plugins/NAME.rb`.

# DESCRIPTION

Plain `elelem` loads plugins only from three directories: the bundled
`lib/elelem/plugins`, `~/.agents/plugins` and `.agents/plugins`.
Nothing requires an installed gem except a provider named with `-p
NAME` or `/provider NAME`, which `Registry#require_gem` loads as
`elelem/NAME`.

So `elelem-tools`, `elelem-mcp`, `elelem-skills` and similar gems do
nothing after `gem install` until the user writes a loader file such as
`~/.agents/plugins/tools.rb` containing `require "elelem/tools"`. The
core README does not say so; elelem.sh documents it on each plugin
page.

Options:

1. **Auto-require**: at `Plugins#load!`, require every installed gem
   whose name starts with `elelem-`, found with `Gem::Specification`.
   Simple, but loads everything installed, including provider gems and
   gems with heavy native code, on every start.
2. **Opt-in list**: read a list of plugin gems from a file, for example
   `~/.agents/plugins.txt` or a line per gem, and require each one.
3. **Gem metadata**: require only gems that mark themselves as plugins
   in their gemspec metadata (for example `elelem_plugin: "true"`).

Whichever is chosen:

* A gem that fails to load is reported the same way as a failing plugin
  file, and does not stop elelem.
* `/reload` keeps the gem-registered setups.
* A user can still turn a gem off without uninstalling it.

At the least, document the loader file in the core README.

# SEE ALSO

* [ ] Formerly elelem-sh/elelem.sh#13
* [ ] lib/elelem/plugins.rb:5 - `LOAD_PATHS`
* [ ] lib/elelem/plugins.rb:16 - `load!`
* [ ] lib/elelem/plugins.rb:31 - `load_plugin`, reports load failures to stderr and the log
* [ ] lib/elelem/registry.rb:55 - `require_gem`, loads provider gems only
* [ ] lib/elelem/registry.rb:32 - `reload`
* [ ] README.md - "Use the plugin API to add more."

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] After `gem install elelem-tools`, `elelem` has its tools with no file in `~/.agents/plugins`
* [ ] The same holds for elelem-mcp and elelem-skills
* [ ] Provider gems are not loaded until their provider is used, unless the chosen design says otherwise
* [ ] A plugin gem that raises on load prints one error line and elelem still starts
* [ ] A user can disable an installed plugin gem without uninstalling it
* [x] `/reload` keeps setups registered by gems (4b5db79)
* [ ] The README explains how plugin gems are found and how to turn one off
