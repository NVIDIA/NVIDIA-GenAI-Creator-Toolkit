# Models — Module 01: LLM Prompt Enhancer

Total storage: ~29 GB + LLM (Ollama)
VRAM: 12–16 GB

## Generation Models

| Model | File | Size | Source |
|-------|------|------|--------|
| Qwen Image 2512 BF16 | `qwen_image_2512_bf16.safetensors` | 13.5 GB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_2512_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder | `qwen_2.5_vl_7b.safetensors` | 14.5 GB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors) |
| Qwen Image VAE | `qwen_image_vae.safetensors` | 170 MB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) |
| Qwen Lightning 8-step FP32 LoRA | `Qwen-Image-2512-Lightning-8steps-V1.0-fp32.safetensors` | 1 GB | [lightx2v/Qwen-Image-2512-Lightning](https://huggingface.co/lightx2v/Qwen-Image-2512-Lightning/resolve/main/Qwen-Image-2512-Lightning-8steps-V1.0-fp32.safetensors) |

> The Qwen Image 2512 stack (diffusion model + text encoder + VAE) is shared with no other module — Module 01 uses the `2512` generation variant, while Modules 03–06 and Bonus A use the `2511 Edit` variant.

## LLM (via Ollama)

Requires [Ollama](https://ollama.com) installed and running locally at `http://127.0.0.1:11434`.

```bash
ollama pull gemma3
```

| Model | Size | Notes |
|-------|------|-------|
| Gemma 3 (default) | 2–7 GB | Handles agent persona + task reasoning |

Gemma 3 can be swapped for any Ollama-compatible model.
