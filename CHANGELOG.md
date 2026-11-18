# Changelog

## [0.14.2](https://github.com/elelem-sh/elelem/compare/v0.14.1...v0.14.2) (2026-11-18)


### Bug Fixes

* **deps:** drop pathname and accept the json, io-console and reline that Ruby 4.0 ships ([784cb79](https://github.com/elelem-sh/elelem/commit/784cb79823da1ca68d85c86e01eaa028fa9114d6))

## [0.14.1](https://github.com/elelem-sh/elelem/compare/v0.14.0...v0.14.1) (2026-11-17)


### Bug Fixes

* validate tool arguments with a small built-in validator instead of json_schemer ([d4160e8](https://github.com/elelem-sh/elelem/commit/d4160e847c78ef927adf5156360e11a235eccc81))

## [0.14.0](https://github.com/elelem-sh/elelem/compare/v0.13.1...v0.14.0) (2026-11-15)


### Features

* the demo reads `@path` with the read tool ([e6a1ab5](https://github.com/elelem-sh/elelem/commit/e6a1ab5529bc510efb178e3a2cd6cf986d391dbf))
* the demo reads any file you name that is not executable ([7b52d42](https://github.com/elelem-sh/elelem/commit/7b52d4291bc7c8d51a90f1230f0a6b28939c8e98))


### Bug Fixes

* streamed command output keeps its blank lines ([feaa7c3](https://github.com/elelem-sh/elelem/commit/feaa7c309923369bdab408dde3475ea19479fbc9))
* the demo reply says the exit status, without repeating the output it just showed ([23cae9f](https://github.com/elelem-sh/elelem/commit/23cae9f235bb88389ab2e65ac346fd61a52368d9))
* waiting dots start after a moment, and end with a line break only when shown ([82da3cf](https://github.com/elelem-sh/elelem/commit/82da3cf98480fa90bb8787d1c44835be3b4ccfb3))

## [0.13.1](https://github.com/elelem-sh/elelem/compare/v0.13.0...v0.13.1) (2026-11-15)


### Bug Fixes

* /provider NAME [MODEL] passes a model only when you type one ([69130c9](https://github.com/elelem-sh/elelem/commit/69130c90d0f69d9c3eacd0edfa74f88aed0bff2d))
* a failed turn leaves the conversation as it was, and five smaller review fixes ([21a9dae](https://github.com/elelem-sh/elelem/commit/21a9dae4d2f17525d56aac8c42ae34d2490142f6))
* ctrl-c stops a running command under the cli's int trap ([c068920](https://github.com/elelem-sh/elelem/commit/c0689209b503cbfde42b2a56e7fe5fadde7c186f))
* execute has no timeout unless ELELEM_CMD_TIMEOUT is set, so commands can prompt on the terminal ([f34ac93](https://github.com/elelem-sh/elelem/commit/f34ac9386419aa940963a53475933df27b6df297))
* plugin load failures reach the log, and ask at a terminal uses the configured output ([eaceeb4](https://github.com/elelem-sh/elelem/commit/eaceeb4f3020b75a2f0db15149ff18cf36ef8496))
* the stub is now the demo provider, a shell plugin that shows how a provider works ([db833f5](https://github.com/elelem-sh/elelem/commit/db833f5ee81d75bde7a9deec7a8d2eb8f8c2ac13))
* warnings go to a private log file, and a piped reply prints as plain text ([5a1cb06](https://github.com/elelem-sh/elelem/commit/5a1cb06337a88e4443958295c90fd164531b06ed))

## [0.13.0](https://github.com/elelem-sh/elelem/compare/v0.12.0...v0.13.0) (2026-11-15)


### Features

* make the stub provider do what you type ([d5c5c0d](https://github.com/elelem-sh/elelem/commit/d5c5c0d9c5f4d272bf5155bcd7ec5c08d411fbf7))
* merge elelem-builtins into core ([cd4fbdd](https://github.com/elelem-sh/elelem/commit/cd4fbddb3258b82866fc52a1cf4319ca8a7c2633))
* the stub understands plain requests and reports like a model ([d6414ac](https://github.com/elelem-sh/elelem/commit/d6414acc263587ef90adafe8a1c29bc466894aa9))
* thread provider options and split template/system_prompt (0.13.0) ([4f802f8](https://github.com/elelem-sh/elelem/commit/4f802f8c74918c0a1275e93fd5f90967a001ee8b))


### Bug Fixes

* /provider NAME [MODEL] keeps --model for the same provider (elelem-sh/elelem.sh[#19](https://github.com/elelem-sh/elelem/issues/19)) ([5bdc39d](https://github.com/elelem-sh/elelem/commit/5bdc39d184d38d729d7be80173f38aaadd07ea34))
* /reload keeps setups registered by gems (elelem-sh/elelem.sh[#6](https://github.com/elelem-sh/elelem/issues/6)) ([4b5db79](https://github.com/elelem-sh/elelem/commit/4b5db79e2c566aa0ae36eebf9399fac74ee152b6))
* /tools copies the tool list so tools added by a loading MCP server cannot break it ([8aee981](https://github.com/elelem-sh/elelem/commit/8aee98143af19525ab48211307510459d804e7db))
* a load error inside an installed provider gem is reported as itself, not as a missing gem ([1de5ce5](https://github.com/elelem-sh/elelem/commit/1de5ce56d941bb46dfeb61a54d8440accf692bb2))
* execute reports ok: false when the command exits non-zero (elelem-sh/elelem.sh[#20](https://github.com/elelem-sh/elelem/issues/20)) ([b94882b](https://github.com/elelem-sh/elelem/commit/b94882bfe0cfe8d555de25fbe8cc1a6c1a9aa26b))
* harden read, execute, write and the repl, and fold single-use classes into their callers ([8e4b338](https://github.com/elelem-sh/elelem/commit/8e4b3387741e74d8d13e0842e6a5cd887dd904b2))
* keep a gem's output instead of replacing it with the terminal ([2353eee](https://github.com/elelem-sh/elelem/commit/2353eee75961cc361c9f25c9eb60a7d6fbfcbbd6))
* leave out missing stub arguments so a bare write cannot empty a file ([de12c55](https://github.com/elelem-sh/elelem/commit/de12c5504af6f295e4ead9855aea03e15cad1f7e))
* print a piped ask reply as plain text, not a code fence ([fa10b15](https://github.com/elelem-sh/elelem/commit/fa10b1582a85f8fb2172862837f9ae7e438f7780))
* return verify results to the model after a write (elelem-sh/elelem.sh[#3](https://github.com/elelem-sh/elelem/issues/3)) ([941ec7e](https://github.com/elelem-sh/elelem/commit/941ec7e4bcbc5d2c5c10e687b6f8393cb689238a))
* show tool errors once without a backtrace and keep prompt answers out of history ([f9a8e8d](https://github.com/elelem-sh/elelem/commit/f9a8e8d32919d088508e168fd1d89986ec195f39))
* the stub never writes to a word that is not a file name ([c5c311c](https://github.com/elelem-sh/elelem/commit/c5c311c3e4419bb4c0b320673456412bfb27d7a1))
* the stub points at /tools only when a call is missing an argument ([51113aa](https://github.com/elelem-sh/elelem/commit/51113aab12a2820a8cbb35d22adbc6a869059f56))

## [0.12.0] - 2026-09-12

### Changed
- **Breaking:** `Agent` split into `Agent` (turn loop only), `Repl` (input
  loop), `Session` (bundles agent+input+commands for setup blocks), and
  `Transcript` (wraps `Conversation`+`SystemPrompt` rendering).
- **Breaking:** `Tool` delegates JSON schema validation to a new `Schema`
  class, reusable outside `Tool`.
- **Breaking:** `Config.build_agent` renamed to `build_session`, returns a
  `Session` instead of an `Agent`. `Registry#apply`/`#reload` now take a
  `Session` instead of an `Agent`.
- Rescue `ScriptError` (in addition to `StandardError`) when loading plugins,
  so a plugin with a syntax error doesn't take down the whole process.
- Load global `~/.agents/AGENTS.md` alongside the project's `AGENTS.md`.

## [0.11.0] - 2026-09-07

### Changed
- **Breaking:** extracted everything provider-, tool-, and transport-specific
  out of core: `lib/elelem/net/*`, `lib/elelem/mcp/*`, `lib/elelem/plugins/*`,
  `providers.rb`, `server.rb`, `web_terminal.rb`, `permissions.rb`, and
  `Elelem.sh`. Moved to `elelem-anthropic`, `elelem-openai`, `elelem-ollama`,
  `elelem-mcp`, `elelem-llama`, `elelem-server`, `elelem-builtins`, and
  `elelem-tools`, with history.
- **Breaking:** `Terminal` split into `Input` (prompting, completion) and
  `Output` (rendering); `Registry`/`Config` split out of a single class into
  `Registry`, `Registration`, and `Config`; `SlashCommand` extracted from
  `Commands` into its own class.
- **Breaking:** `Registry#build` renamed to `build_provider` (was
  `build_client`); `Agent#client` renamed to `Agent#provider`; provider
  implementations are named `Provider`, not `Client`, across every provider
  gem.
- **Breaking:** `Commands#include?` removed (zero callers); `#command_for`
  is now private.
- Added `Elelem::StubProvider`, registered at `provider: :stub`, so a
  freshly-installed elelem with zero plugin gems still runs and terminates
  instead of raising.
- `exe/elelem` requires `elelem/builtins` if installed, rescuing `LoadError`.
- `.elelem/` renamed to `.agents/`.

## [0.10.0] - 2026-01-27

### Changed
- **Breaking: Plugin API** - plugins now receive `agent` instead of `toolbox`
  - Old: `Elelem::Plugins.register(:name) { |toolbox| toolbox.add(...) }`
  - New: `Elelem::Plugins.register(:name) { |agent| agent.toolbox.add(...) }`
  - Plugins can now access `agent.terminal`, `agent.commands`, `agent.conversation`
- Extracted `Conversation` class from `Agent` for better separation of concerns
- Extracted `Commands` class for slash command handling
- Refactored LLM fetch interface to emit separate events for thinking/content/tool_calls
- Simplified system prompt with inline ERB template
- Renamed confirm plugin to `zz_confirm` to ensure it loads last
- MCP logs now write to `~/.elelem/mcp.log` instead of working directory
- Tool schema now frozen to prevent mutation
- Uses `Open3.capture2` instead of backticks for thread safety
- Improved ANSI escape sequence stripping in `/shell` transcripts

### Added
- **Async MCP loading** for faster startup - tools load in background thread
- **HTTP MCP servers** with SSE support and session management
- **OAuth authentication** for MCP servers with PKCE, automatic token refresh
- **Global hooks** - `toolbox.before`/`toolbox.after` without tool name applies to all tools
- **`/context` improvements**: `/context <n>` to view entry, `/context json` for full dump
- **ast-grep (`sg`) support** for building repo maps - faster and more accurate than ctags
- **New tools**: `glob`, `grep`, `list`, `git`, `task`, `/tools` command
- **Permissions system** (`lib/elelem/permissions.rb`) for tool access control
- **OpenAI reasoning mode** - enables `Reasoning: high` for o-series models
- **Test coverage** for OAuth, token storage, HTTP MCP, SSE parsing, global hooks

## [0.9.2] - 2026-01-22

### Fixed
- Suppress pathname gem constant redefinition warnings on Ruby 4.0

## [0.9.1] - 2026-01-22

### Fixed
- Use `next` instead of `return` to exit block in execute plugin after-hook
- Use `break` instead of `return` to exit `inject` block in verify plugin

## [0.9.0] - 2026-01-21

### Changed
- **Breaking**: Requires Ruby >= 4.0.0 (was 3.4.0)
- **Breaking**: Removed `net-llm` dependency - LLM clients now inline in `lib/elelem/net/`
  - `Elelem::Net::Claude` (Anthropic and Vertex AI)
  - `Elelem::Net::OpenAI`
  - `Elelem::Net::Ollama`
- **Breaking**: Simplified LLM client `fetch` contract
  - Yields `{content:, thinking:}` deltas
  - Returns `tool_calls` array directly
- **Breaking**: Tool schema uses OpenAI format (`{type: "function", function: {...}}`)
- **Breaking**: Tool definitions use `description:` key (was `desc:`)
- **Breaking**: Removed modes and permissions system entirely
- **Breaking**: Removed slash commands (`/mode`, `/env`, `/provider`, `/model`)
  - Remaining: `/clear`, `/context`, `/init`, `/reload`, `/shell`, `/exit`, `/help`
- **Breaking**: Removed many dependencies
  - Removed: `thor`, `cli-ui`, `erb`, `cgi`, `set`, `timeout`, `logger`, `net-llm`, `json-schema`
  - Added: `json_schemer`, `optparse`, `tempfile`, `stringio`, `uri`
- Consolidated multiple exe files into single `exe/elelem` entry point
- Tools are now defined via plugins instead of hardcoded in Toolbox
- System prompt includes hints for `rg`, `fd`, `sg` (ast-grep), `sed`, `patch`
- System prompt regenerated on each fetch (includes dynamic repo map)
- Default tool set: `read`, `write`, `edit`, `execute`, `eval`, `verify`, `task`
- System prompt encourages using `eval` to create tools for repetitive tasks

### Added
- **Plugin system** with support for custom tool definitions
  - Load plugins from `lib/elelem/plugins/`, `~/.elelem/plugins/`, and `.elelem/plugins/`
  - `Elelem::Plugins.register(name) { |toolbox| ... }` API
  - Built-in plugins: `read`, `write`, `edit`, `execute`, `eval`, `verify`, `confirm`, `mcp`
- **MCP (Model Context Protocol)** server support via `.mcp.json` configuration
- **AGENTS.md** file support - searches up directory tree for project instructions
- **`/init` command** to generate an AGENTS.md file for the current project
- **`/shell` command** to drop into a shell session and capture the transcript to context
- **`/reload` command** to hot-reload source code without restarting the process
- **`task` tool** for delegating subtasks to focused sub-agents
- **`edit` tool** for replacing first occurrence of text in a file
- **`eval` tool** for executing Ruby code and dynamically registering new tools
- **`verify` tool** for syntax checking and running project tests
- **Pre/post tool hooks** (`toolbox.before`/`toolbox.after`) for extensibility
- **Confirmation prompt** before executing shell commands (when TTY)
- **Context compaction** for long conversations (summarizes old messages)
- **Repo map** via ctags included in system prompt
- **Markdown rendering** with [glow](https://github.com/charmbracelet/glow) for LLM responses
- **CLI improvements**: optparse-based interface with `-p`/`-m` flags
  - `elelem chat` - Interactive REPL (default)
  - `elelem ask <prompt>` - One-shot query (reads stdin if piped)
  - `elelem files` - Output files as XML
- JSON Schema validation for tool call arguments (via `json_schemer`)
- Tool aliases support (e.g., `bash`, `sh`, `exec` for `execute`)
- **Dependencies documentation** in README with installation links

### Removed
- `lib/elelem/application.rb` - CLI now in `exe/elelem`
- `lib/elelem/conversation.rb` - simplified into Agent
- `lib/elelem/git_context.rb` - inlined into Agent
- `lib/elelem/system_prompt.erb` - now generated in Agent
- `web_fetch`, `web_search`, `fetch`, `search_engine` tools
- `patch` tool (use `edit` or `execute` with `sed`/`patch`)
- `grep`, `list` tools (use `execute` with `rg`, `fd`)
- Modes and permissions system
- Events module
- GitHub Actions CI workflow

### Fixed
- Handle missing args in Claude provider
- Tool alias resolution (use canonical tool name, not alias)
- Unknown tool error now suggests using `execute` and lists available tools
- Duplicate write operations in edit flow

## [0.8.0] - 2026-01-14

### Added
- `fetch` tool for HTTP GET requests (returns status and body)
- `search_engine` tool for DuckDuckGo Instant Answer API searches
- Tool aliases: `get`/`web` for `fetch`, `ddg`/`duckduckgo` for `search_engine`
- `net-hippie` and `cgi` dependencies for HTTP requests

## [0.7.0] - 2026-01-14

### Changed
- Renamed internal `mode` concept to `permissions` for clarity (read/write/execute are permissions, plan/build/verify are modes)
- Refactored `Toolbox#run_tool` to accept `permissions:` parameter

### Added
- ASCII spinner animation while waiting for LLM responses
- `Terminal#waiting` method with automatic cleanup on next output
- Decision-making principles in system prompt (prefer reversible actions, ask when uncertain)
- Mode enforcement tests

### Fixed
- **Security**: Mode restrictions now enforced at execution time, not just schema time
  - Previously, LLMs could call tools outside their mode by guessing tool names
  - Now `run_tool` validates the tool is allowed for the current permission set

## [0.6.0] - 2026-01-12

### Changed
- Renamed `bash` tool to `exec`
- Tuned system prompt
- Changed thinking prompt to ellipsis
- Removed username from system prompt
- Use pessimistic constraint on net-llm dependency
- Extracted Terminal class for IO abstraction (enables E2E testing)

### Added
- `/env` slash command to capture environment variables for provider connections
- `/shell` slash command
- `/provider` and `/model` slash commands
- Tab completion for commands
- Help output for `/mode` and `/env` commands

### Fixed
- Prevent infinite looping errors
- Provide function schema when tool is called with invalid arguments
- Tab completion for `pass` entries without requiring `show` subcommand
- Password store symlink support in tab completion

## [0.5.0] - 2026-01-07

### Changed
- Requires net-llm >= 0.5.0 with unified fetch interface
- Updated gem description to reflect multi-provider support

### Added
- Multi-provider support: Ollama, Anthropic, OpenAI, and VertexAI
- `--provider` CLI option to select LLM provider (default: ollama)
- `--model` CLI option to override default model
- Tool aliases (`bash` also accepts `exec`, `shell`, `command`, `terminal`, `run`)
- Thinking text output for models that support extended thinking

## [0.4.2] - 2025-12-01

### Changed
- Renamed `exec` tool to `bash` for clarity
- Improved system prompt with iterative refinements
- Added environment context variables to system prompt

## [0.4.1] - 2025-11-26

### Changed
- Refactor tool-call formatting to a more compact JSON payload for better LLM parsing
- Updated CI and documentation to use GitHub instead of previous hosting
- Runtime validation of command-line parameters against a JSON schema

### Added
- `elelem files` subcommand: generates Claude-compatible XML file listings
- Rake task `files:prompt` to output a ready-to-copy list of files for prompts

### Fixed
- Minor documentation and CI workflow adjustments

## [0.4.0] - 2025-11-10

### Changed
- **Architecture Improvements**: Significant refactoring for better separation of concerns
  - Extracted Tool class to separate file (`lib/elelem/tool.rb`)
  - Extracted Toolbox class to separate file (`lib/elelem/toolbox.rb`)
  - Extracted Shell class for command execution
  - Improved tool registration through `#add_tool` method
  - Tool constants moved to Toolbox for better organization
  - Agent class simplified by delegating to Tool instances

### Added
- **Eval Tool**: Meta-programming tool that allows the LLM to dynamically create and register new tools at runtime
  - Eval tool has access to the toolbox for enhanced capabilities
- Comprehensive test coverage with RSpec
  - Agent specs
  - Conversation specs
  - Toolbox specs

### Fixed
- `/context` command now correctly accounts for the current mode

## [0.3.0] - 2025-11-05

### Changed
- **Breaking**: Removed `llm-ollama` and `llm-openai` standalone executables (use main `elelem chat` command)
- **Breaking**: Simplified architecture - consolidated all logic into Agent class
  - Removed Configuration class
  - Removed Toolbox system
  - Removed MCP client infrastructure
  - Removed Tool and Tools classes
  - Removed TUI abstraction layer (direct puts/Reline usage)
  - Removed API wrapper class
  - Removed state machine
- Improved execute tool description to guide LLM toward direct command execution
- Extracted tool definitions from long inline strings to readable private methods
- Updated README with clear philosophy and usage examples
- Reduced total codebase from 417 to 395 lines (-5%)

### Added
- **Mode System**: Control agent capabilities with workflow modes
  - `/mode plan` - Read-only mode (grep, list, read)
  - `/mode build` - Read + Write mode (grep, list, read, patch, write)
  - `/mode verify` - Read + Execute mode (grep, list, read, execute)
  - `/mode auto` - All tools enabled
  - Each mode adapts system prompt to guide appropriate behavior
- Improved output formatting
  - Suppressed verbose thinking/reasoning output
  - Clean tool call display (e.g., `date` instead of full JSON hash)
  - Mode switch confirmation messages
  - Clear command feedback
- Design philosophy documentation in README
- Mode system documentation

### Removed
- `exe/llm-ollama` (359 lines)
- `exe/llm-openai` (340 lines)
- `lib/elelem/configuration.rb`
- `lib/elelem/toolbox.rb` and toolbox/* files
- `lib/elelem/mcp_client.rb`
- `lib/elelem/tool.rb` and `lib/elelem/tools.rb`
- `lib/elelem/tui.rb`
- `lib/elelem/api.rb`
- `lib/elelem/states/*` (state machine infrastructure)
- Removed ~750 lines of unused/redundant code

### Fixed
- Working directory handling for execute tool (handles empty string cwd)
- REPL EOF handling (graceful exit when input stream ends)
- Tool call formatting now shows clean, readable commands

## [0.2.1] - 2025-10-15

### Fixed
- Added missing `exe/llm-ollama` and `exe/llm-openai` files to gemspec
- These executables were added in 0.2.0 but not included in the packaged gem

## [0.2.0] - 2025-10-15

### Changed
- **Breaking**: Migrated from custom Net::HTTP implementation to `net-llm` gem
- API client now uses `Net::Llm::Ollama` for better reliability and maintainability
- Removed direct dependencies on `net-http` and `uri` (now transitive through net-llm)
- Maps Ollama's `thinking` field to internal `reasoning` field
- Maps Ollama's `done_reason` to internal `finish_reason`
- Improved system prompt for better agent behavior
- Enhanced error handling and logging

### Added
- New `llm-ollama` executable - minimal coding agent with streaming support for Ollama
- New `llm-openai` executable - minimal coding agent for OpenAI/compatible APIs
- Memory feature for persistent context storage and retrieval
- Web fetch tool for retrieving and analyzing web content
- Streaming responses with real-time token display
- Visual "thinking" progress indicators with dots during reasoning phase

### Fixed
- Response processing for Ollama's native message format
- Tool argument parsing to handle both string and object formats
- Safe navigation operator usage to prevent nil errors

## [0.1.2] - 2025-08-14

### Fixed
- Fixed critical bug where bash tool had nested parameters schema causing tool calls to fail with "no implicit conversion of nil into String" error

## [0.1.1] - 2025-08-12

### Fixed
- Fixed infinite loop bug after tool execution - loop now continues until assistant provides final response
- Fixed conversation history accumulating streaming chunks as separate entries - now properly combines same-role consecutive messages
- Improved state machine logging with better debug output

## [0.1.0] - 2025-08-08

- Initial release

[0.10.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.9.2...v0.10.0
[0.9.2]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.9.1...v0.9.2
[0.9.1]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.9.0...v0.9.1
[0.9.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.8.0...v0.9.0
[0.8.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.7.0...v0.8.0
[0.7.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.6.0...v0.7.0
[0.6.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.5.0...v0.6.0
[0.5.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.4.2...v0.5.0
[0.4.2]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.4.1...v0.4.2
[0.4.1]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.4.0...v0.4.1
[0.4.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.3.0...v0.4.0
[0.3.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.2.1...v0.3.0
[0.2.1]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.2.0...v0.2.1
[0.2.0]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.1.3...v0.2.0
[0.1.2]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.1.1...v0.1.2
[0.1.1]: https://src.mokhan.ca/xlgmokha/elelem/compare/v0.1.0...v0.1.1
[0.1.0]: https://src.mokhan.ca/xlgmokha/elelem/releases/tag/v0.1.0
