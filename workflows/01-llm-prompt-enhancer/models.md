# Models — Module 01: LLM Prompt Enhancer

Total storage: ~29 GB + LLM (Ollama)
VRAM: 12–16 GB

## Primary Generation Model

| Model | Size | Source |
|-------|------|--------|
| Qwen Image 2512 BF16 | 13.5 GB | `Qwen/Qwen-Image-2512` |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB | `Qwen/Qwen2.5-VL-7B` |
| Qwen Image VAE | 170 MB | bundled with Qwen Image 2512 |
| Qwen Lightning 4-step LoRA | 1 GB | `lightx2v/Qwen-Image-Lightning` |

## LLM Brain (via Ollama)

Requires [Ollama](https://ollama.com) installed and running locally at `http://127.0.0.1:11434` before executing the workflow.

```bash
ollama pull gemma3
```

| Model | Size | Notes |
|-------|------|-------|
| Gemma 3 (default) | 2–7 GB | Runs via Ollama; handles agent persona + task reasoning |

Gemma 3 can be swapped for any Ollama-compatible model (Qwen2.5, LLaMA 3.1, etc.).
