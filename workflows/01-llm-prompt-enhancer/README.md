# Module 01 — LLM Prompt Enhancer

Build an AI agent that automatically refines and strengthens text prompts before they reach a generation model.

---

## What It Does

Different diffusion models expect different prompt formats — Flux, Wan, SDXL, and others each have their own token ordering and phrasing requirements. Writing good prompts by hand for each model is slow and inconsistent.

This workflow chains a local LLM (running via Ollama) with a generation model. The LLM acts as an agent: it reads your plain-language instruction and translates it into a structured, model-ready prompt automatically.

**Pipeline**

```
User Instruction
    └── Prompt Enhancement Agent (Gemma 3 via Ollama)
            └── Text Encoding + Conditioning
                    └── Generated Image
```

**Agent Structure**

| Component | Role |
|-----------|------|
| **Brain** | The LLM model (Gemma 3, Qwen, LLaMA) |
| **Persona** | The agent's identity — its rules, tone, decision style |
| **Task** | Your immediate instruction, examples, and constraints |

---

## Models

See [models.md](models.md) — total storage ~29 GB + LLM

| Model | Size |
|-------|------|
| Qwen Image 2512 BF16 | 13.5 GB |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB |
| Qwen Image VAE | 170 MB |
| Qwen Lightning 8-step FP32 LoRA | 1 GB |
| Gemma 3 (via Ollama) | 2–27 GB (see below) |

---

## Requirements

- VRAM: 12–16 GB
- [Ollama](https://ollama.com/download) installed and running before launching the workflow

**Pull the LLM:**

```bash
ollama pull gemma3        # pulls gemma3:4b by default (~5 GB, works on 8GB+ VRAM)
ollama pull gemma3:2b     # lighter option for lower VRAM
ollama pull gemma3:12b    # higher quality, needs 16GB+ VRAM
```

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-WJNodes](https://github.com/807502278/ComfyUI-WJNodes) | Utility nodes including RegexExtract |
| [comfyui-ollama](https://github.com/stavsap/comfyui-ollama) | Connects ComfyUI to the local Ollama API |

---

## Usage

**1. Install and start Ollama**

- **Windows:** Download the installer from https://ollama.com/download and run it. Ollama starts automatically as a background service.
- **Linux:** `curl -fsSL https://ollama.com/install.sh | sh` — this registers a systemd service that starts automatically. Do not run `ollama serve` manually if using the official installer (it will conflict).

**2. Pull a model:**
```bash
ollama pull gemma3
```

**3. Install custom nodes** listed in [nodes.md](nodes.md) via ComfyUI Manager

**4. Download models** listed in [models.md](models.md)

**5. Drag `workflow.json` into ComfyUI**, enter your instruction, and queue
