As a `user of a slow local provider`, I `want the reply to appear as it is written`, so that `I am not staring at a spinner for a minute`.

# SYNOPSIS

Print `saying` events as they arrive instead of once at the end of the turn.

# DESCRIPTION

`Agent#fetch` collects every `saying` event and calls `output.say(content, as: :markdown)`
once, after the provider returns. `thinking` events print live.

That is fine for hosted providers that send the reply in one go. On a
CPU provider it is not: elelem-candle decodes the 4B model at about
3 tokens a second, so a 200 token reply shows only the spinner for about
70 seconds. Providers work around it by streaming the reply as
`thinking`, which then prints twice.

Let providers yield `saying` events in pieces and print each piece as it
arrives, then render the joined text as markdown once at the end (or
leave it as plain text when it was already streamed). The joined text
stays the assistant message stored in the conversation.

# SEE ALSO

* [ ] lib/elelem/agent.rb - fetch, stream
* [ ] lib/elelem/output.rb - say, thinking
* [ ] lib/elelem/terminal.rb - say
* [ ] elelem-candle lib/elelem/candle/provider.rb - fetch

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] Each `saying` piece prints as it arrives
* [ ] The stored assistant message is the joined text
* [ ] Providers that send one `saying` event look the same as today
* [ ] No text is printed twice
