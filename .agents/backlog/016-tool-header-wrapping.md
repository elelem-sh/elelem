As a `user`, I `want tool headers to handle long parameters gracefully`, so that `the output remains readable without ugly line wrapping`.

# SYNOPSIS

Truncate or format tool header parameters to prevent multi-line wrapping.

# DESCRIPTION

When tools are invoked with long parameters (e.g., long file paths, large
content), the header line wraps awkwardly across multiple lines, making
the output hard to read.

Options to consider:
1. Truncate parameters with ellipsis (e.g., `content: "Lorem ipsum..."`)
2. Show only parameter names, not values
3. Limit total header width to terminal width
4. Multi-line but intentionally formatted (key: value on separate lines)

# SEE ALSO

* [ ] lib/elelem/output.rb:25 - `Output#doing`, prints `+ name(args)` with `args` as a Hash
* [ ] lib/elelem/builtins/terminal.rb:22 - `Terminal#doing`, adds a gap first
* [ ] lib/elelem/agent.rb:58 - `process` calls `output.doing` for each tool call
* [ ] lib/elelem/plugins/execute.rb:16 - after hook prints `x execute(args)` on failure

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] Tool headers never wrap unintentionally
* [ ] Long string parameters are truncated with ellipsis
* [ ] Parameter preview length is configurable or sensible default
* [ ] Full parameters still visible in verbose/debug mode if needed
* [ ] Headers remain informative (user knows what tool is running)

## Examples

| Actual (current) | Expected (new) |
|------------------|----------------|
| `+ execute({"command" => "bin/test"})` | `+ execute(bin/test)` |
| `+ interview({"question" => "Excellent! So the priority order is..."})` (multi-line) | `+ interview("Excellent! So the priority order is..."...)` |
| `+ write("README.md", "Hello world, this is my very long paragraph.")` | `+ write("README.md", "Hello world, this is"...)` |

**Rules:**
1. Strip hash syntax (`{"key" => value}`) - show values directly
2. For single-param tools, show value without key name
3. Truncate strings at ~50 chars with `...`
4. For multi-param tools: `+ tool(param1, param2, ...)`
5. File paths: show full path (usually short enough)
