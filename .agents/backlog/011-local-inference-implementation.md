As a `new user`, I `want elelem to run a local model without external servers or API keys`, so that `I can start using it with no configuration`.

# SYNOPSIS

Finish local inference: fetch a model on first run, and point new users at it.

# DESCRIPTION

Most of this story has shipped in `elelem-llama` (0.3.0 on RubyGems,
more on its main branch):

* llama.cpp is vendored and compiled at `gem install`, then called
  through `fiddle`. The spike (archived story 001) chose this approach.
* The backend is picked at build time: Metal on macOS, else CUDA if
  `nvcc` is found, Vulkan, ROCm/HIP, or CPU. `ELELEM_LLAMA_BACKEND`
  forces one.
* At load time, layers go to the GPU only when the model fits in free
  GPU memory (`gpu_free_memory`), else the model runs on the CPU.
* `-p llama` (or the `elelem-llama` executable) loads a GGUF model from
  `--model`, `ELELEM_GGUF_MODEL`, `~/.agents/models/default.gguf`, or
  the only `*.gguf` in `~/.agents/models`.
* Core's demo provider tells a user with no model to
  `gem install elelem-llama`, then run `elelem -p llama`.

What remains:

1. **Model download.** With no model in `~/.agents/models`, the provider
   raises "no .gguf model found". It should offer to download a small
   default coding model from Hugging Face instead, show progress, resume
   an interrupted download, and pin the file by URL and SHA-256.
2. **Model choice by hardware.** Pick the size of the downloaded model
   from free GPU memory (already measured for offload) or system RAM,
   for example 7B with 8GB+ free VRAM, 3B with 4GB, 1-3B on CPU only.
3. **First run.** A new user who installs `elelem-llama` and runs
   `elelem -p llama` gets a working chat with no other step.

Making a local provider the default when no `-p` is given is covered by
story 026 (default provider), not here. Story 022 (`elelem-onnx`) is a
smaller local provider that needs no compiler.

# SEE ALSO

* [ ] llama/lib/elelem/llama.rb - provider registration and GPU offload choice
* [ ] llama/lib/elelem/llama/model_resolver.rb - model lookup in `~/.agents/models`
* [ ] llama/ext/elelem/llama/extconf.rb - `detect_backend` (metal, cuda, vulkan, hip, cpu)
* [ ] llama/lib/elelem/llama/provider.rb:18 - `gpu_free_memory`
* [ ] lib/elelem/plugins/demo.rb:14 - `install_hint` that suggests `elelem-llama`
* [ ] .agents/backlog/archive/001-local-inference-spike.md - the spike
* [ ] .agents/backlog/022-elelem-onnx.md - no-compiler local provider
* [ ] .agents/backlog/026-default-provider.md - default provider and notice

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [x] Provider loads a GGUF model from local disk
* [x] Provider works with GPU acceleration (CUDA, ROCm, Vulkan or Metal)
* [x] Provider falls back to CPU when no GPU backend was built, or the model does not fit
* [x] Provider integrates with the existing conversation flow
* [ ] With no model present, `elelem -p llama` offers to download one
* [ ] The user sees progress while the model downloads
* [ ] An interrupted download resumes instead of starting over
* [ ] The downloaded file is checked against a pinned SHA-256
* [ ] The model is stored in `~/.agents/models` and not downloaded again
* [ ] A failed download prints a clear error and leaves no partial model in place
* [ ] The default model size follows the detected GPU memory or system RAM
* [ ] Works fully offline once the model is downloaded
