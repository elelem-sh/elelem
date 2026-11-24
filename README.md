# Elelem

Fast, correct, autonomous - pick two.

## Purpose

Elelem is a minimal coding harness. The agent exposes a simple text-based UI.

## Design Principles

* Unix philosophy - simple, composable, minimal.
* Convention over configuration.
* No defensive checks or complexity beyond what is necessary.
* Assumes a mature, responsible LLM that behaves like a capable engineer.

## Installation

Install the gem directly:

```bash
gem install elelem
```

## Usage

Start elelem:

```bash
elelem
```

`elelem "question"` answers once and reads a pipe. `elelem --sock PATH` serves the
session on a Unix socket, and `elelem --sock PATH "question"` asks the agent there.
Connecting gives the powers of a shell, so the socket is open to its owner alone.

## Tools

elelem ships with `read`, `write` and `execute`. Use the plugin API to add more.

## Contributing

```bash
git clone https://github.com/elelem-sh/elelem.git
```

Send me a patch via email. For instructions see https://git-send-email.io/.

## License

MIT. See the bundled `LICENSE.txt`.
