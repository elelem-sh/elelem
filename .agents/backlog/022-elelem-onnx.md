As a `user`, I `want to run a small model in-process with no compiler`, so that `a local model works right after gem install`.

# SYNOPSIS

`elelem-onnx`: a provider gem that runs small ONNX models through the prebuilt `onnxruntime` gem.

# DESCRIPTION

`elelem-llama` compiles llama.cpp at install. `onnxruntime` ships prebuilt
binaries for Linux, macOS and Windows, so nothing compiles.

1. **Provider** `-p onnx`, in its own gem, not in core
2. **Tokenizer** in Ruby, from `tokenizer.json`
3. **Loop**: generate token by token with a KV cache, apply the chat template, parse tool calls
4. **Model** downloaded on first run, pinned by URL and SHA-256

Candidates: Qwen2.5-0.5B-Instruct, Qwen3-0.6B, SmolLM2-360M-Instruct.
Measure speed and tool use before picking one.

# SEE ALSO

* [ ] https://rubygems.org/gems/onnxruntime
* [ ] ggml/lib/elelem/ggml/tokenizer.rb - a Ruby BPE tokenizer
* [ ] llama/lib/elelem/llama/model_resolver.rb - model lookup in ~/.agents/models
