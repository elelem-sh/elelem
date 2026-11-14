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

## Tools

elelem ships with `read`, `write` and `execute`. Use the plugin API to add more.

## Models

Without a model, elelem does what you type: `read README.md`, `execute ls`.
For a real model, install a provider:

```bash
gem install elelem-llama
elelem -p llama
```

Read the docs at https://elelem.sh.

## Contributing

```bash
git clone https://github.com/elelem-sh/elelem.git
```

Send me a patch via email. For instructions see https://git-send-email.io/.

## License

MIT – see the bundled `LICENSE.txt`.
