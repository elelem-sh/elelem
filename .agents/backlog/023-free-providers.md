As a `user`, I `want -p NAME plus a free key to reach a free provider`, so that `elelem works right after gem install, at no cost`.

# SYNOPSIS

One small gem per free vendor, each built on `elelem-openai`.

# DESCRIPTION

One gem per vendor, so a vendor's API change is fixed and released in
its own gem:

| gem                    | `-p`            | key variable            |
|------------------------|-----------------|-------------------------|
| `elelem-groq`          | `groq`          | `GROQ_API_KEY`          |
| `elelem-openrouter`    | `openrouter`    | `OPENROUTER_API_KEY`    |
| `elelem-gemini`        | `gemini`        | `GEMINI_API_KEY`        |
| `elelem-cerebras`      | `cerebras`      | `CEREBRAS_API_KEY`      |
| `elelem-mistral`       | `mistral`       | `MISTRAL_API_KEY`       |
| `elelem-github`        | `github`        | `GITHUB_API_KEY`        |
| `elelem-cloudflare`    | `cloudflare`    | `CLOUDFLARE_API_TOKEN`  |

1. **Gem**: one file, `lib/elelem/NAME.rb`. It requires `elelem/openai`
   and registers provider `NAME` with
   `Elelem::OpenAI::Provider.new(model:, api_key:, base_url:)`, the same
   way `openai/lib/elelem/openai.rb:14` does. `Registry#require_gem` does
   `require "elelem/#{name}"` when `-p NAME` or `/provider NAME` is not yet
   registered, so `gem install elelem-groq` then `elelem -p groq` starts a
   session.
2. **Env**: each gem reads its own `NAME_API_KEY`, `NAME_MODEL`,
   `NAME_BASE_URL`. An empty value counts as unset, with the same lambda
   as `openai.rb:16`. Cloudflare keeps its own `CLOUDFLARE_API_TOKEN` and
   also needs `CLOUDFLARE_ACCOUNT_ID` for its base URL. `elelem-github`
   reaches GitHub Models.
3. **Model**: `--model` or `NAME_MODEL`. If neither is set, the error names
   the variable. No default model, since free model lists change often.
4. **Quirks** stay in the vendor gem: a subclass of
   `Elelem::OpenAI::Provider` overrides `build_request_body` or
   `handle_event` / `accumulate_tool_calls` only where the vendor differs.
5. **Verify** each against the vendor's docs and a real tool-calling run on
   a free key. `accumulate_tool_calls` keys on `index`; a vendor that sends
   parallel tool calls with no `index` merges them under `nil`, keeping the
   first id and name and joining the arguments, so `finalize_tool_calls`
   raises `JSON::ParserError`.
6. **Gemini**: a native `elelem-gemini` speaking `generateContent` only if
   its OpenAI-compatible endpoint fails the tool-calling run in item 5.
   The gem name stays the same either way.
7. **Docs**: a plugin page per gem on elelem.sh, and a "Try elelem for
   free" guide with one tested recipe per vendor. Link each vendor's own
   limits page; quote no numbers.

Names: RubyGems has no namespaces, and its policy treats gems that only
hold a name as squatting. Each 0.1.0 ships working code, so claiming the
name is real use. `elelem-groq` and `elelem-gemini` were checked free;
check the rest before creating repos.

What the user does:

* Create a repo for each gem and set up trusted publishing on RubyGems
* Supply a free key per vendor through the secure credential form

# SEE ALSO

* [ ] lib/elelem/registry.rb:15 - `build_provider`
* [ ] lib/elelem/registry.rb:60 - `require_gem`, does `require "elelem/#{name}"`
* [ ] lib/elelem/provider_switch.rb:13 - `/provider NAME` takes the same path
* [ ] openai/lib/elelem/openai.rb:14 - provider registration and `env` lambda
* [ ] openai/lib/elelem/openai/provider.rb:6 - `Provider#initialize(model:, api_key:, base_url:)`
* [ ] openai/lib/elelem/openai/provider.rb:29 - `build_request_body`
* [ ] openai/lib/elelem/openai/provider.rb:49 - `handle_event`
* [ ] openai/lib/elelem/openai/provider.rb:57 - `accumulate_tool_calls`, keys on `index`
* [ ] https://guides.rubygems.org/trusted-publishing/

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] Each gem name is checked free on RubyGems before its repo is created
* [ ] Each gem depends on `elelem-openai` and ships working code in 0.1.0
* [ ] `gem install elelem-NAME` then `elelem -p NAME` with `NAME_API_KEY` set starts a session
* [ ] `NAME_MODEL` or `--model` picks the model
* [ ] With no model set, the error names `NAME_MODEL`
* [ ] With no key set, the error names the key variable
* [ ] An empty variable counts as unset
* [ ] `NAME_BASE_URL` overrides the vendor's endpoint
* [ ] `elelem -p cloudflare` without `CLOUDFLARE_ACCOUNT_ID` errors naming it
* [ ] Vendor quirks live in a `Provider` subclass in the vendor gem, not in `elelem-openai`
* [ ] Each gem passes a real tool-calling run, including parallel tool calls, on a free key
* [ ] Each gem has a plugin page on elelem.sh
* [ ] The "Try elelem for free" guide has one tested recipe per vendor and links each vendor's limits page, with no numbers
