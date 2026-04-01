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
| Qwen Lightning 4-step LoRA | 1 GB |
| Gemma 3 (via Ollama) | 2–7 GB |

---

## Requirements

- [Ollama](https://ollama.com/download) installed and running before launching the workflow
- VRAM: 12–16 GB

```bash
ollama pull gemma3
```

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-Ollama](https://github.com/stavsap/ComfyUI-Ollama) | Connects ComfyUI to the local Ollama API |

---

## Usage

1. Install Ollama and pull a model: `ollama pull gemma3`
2. Start Ollama: `ollama serve`
3. Install custom nodes listed in [nodes.md](nodes.md) via ComfyUI Manager
4. Confirm models are downloaded (see [models.md](models.md))
5. Drag `workflow.json` into ComfyUI
6. Enter your base instruction in the prompt node
7. Queue
