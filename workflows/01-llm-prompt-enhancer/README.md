![](images/preview.png)

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

## Tips for Best Results

- **Start with a strong seed concept.** The LLM amplifies what you give it — a vague input like "a forest" produces generic output. Give it a directional phrase with intent: "a dense pine forest at dusk with god rays and mist." The more signal in your seed, the more useful the expansion.
- **Include the target mood or style explicitly.** Gemma 3 will infer style if you leave it out, but it often defaults to neutral-cinematic. If you want painterly, noir, isometric, or hyperrealistic, say so in the instruction. The agent is better at amplifying a stated style than inventing the right one.
- **Tune the system prompt persona for your use case.** The default persona is general-purpose. If you're generating product shots, swap in a persona that prioritizes clean backgrounds, studio lighting, and material fidelity. If you're doing concept art, bias toward dynamic composition and environmental storytelling. The persona is where the most leverage lives.
- **Watch for prompt hallucination.** Larger models (12b) stay on-topic better than smaller ones (2b). If the enhanced prompt wanders into unrelated territory — adding objects or scenes you didn't ask for — try tightening the task prompt with explicit "do not add" constraints, or switch to a larger model.
- **Use the enhanced prompt as a starting point, not a final answer.** Read the LLM output before queueing generation. If a line clearly conflicts with your intent, edit it. You understand the creative goal; the LLM is filling in texture, not making decisions.
- **Model size vs. quality trade-off is real.** gemma3:2b is fast and low-VRAM but produces flatter enhancements. gemma3:12b adds noticeably richer material descriptions and lighting logic but doubles generation time. For iteration, use 2b; for final polish, switch to 12b.
- **Avoid stacking multiple style instructions.** Telling the agent "cinematic, impressionist, hyperrealistic, and anime" creates contradictions it will resolve inconsistently. Pick one dominant aesthetic and one optional modifier.
- **If outputs look flat or repetitive across runs**, vary the temperature setting in the Ollama node. A higher temperature (0.8–1.0) produces more unexpected enhancements; lower (0.3–0.5) gives more consistent structure but less creative range.
- **Test with the downstream model in mind.** A prompt optimized for Flux may underperform with SDXL. If you're switching diffusion backends, update the task prompt to tell the agent which model it's writing for — token ordering and emphasis conventions differ significantly.

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
