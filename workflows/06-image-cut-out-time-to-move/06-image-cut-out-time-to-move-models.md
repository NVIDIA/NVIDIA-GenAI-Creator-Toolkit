# Models — Module 06: Cutout Animation to Video (Wan TTM)

Pre-download strongly recommended — Wan2.2 is large.

VRAM: 16–24 GB
Platform: Windows x86_64 and Linux x86_64 only

## Wan2.2 (TTM video generation)

| Model | Size | Destination | Source |
|-------|------|-------------|--------|
| Wan2.2 I2V 480P | ~28 GB | `ComfyUI/models/video/wan` (set via `--local-dir` in download command) | `Wan-AI/Wan2.2-I2V-14B-480P` |
| UMT5-XXL (text encoder) | ~10 GB | `ComfyUI/models/video/wan` (bundled with Wan2.2) | bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | `ComfyUI/models/video/wan` (bundled with Wan2.2) | bundled with Wan2.2 |

```bash
hf download Wan-AI/Wan2.2-I2V-14B-480P --local-dir ComfyUI/models/video/wan
```

## VideoPrep models (prerequisite)

| Model | File | Size | Destination | Source |
|-------|------|------|-------------|--------|
| Qwen Image Edit 2511 BF16 | `qwen_image_edit_2511_bf16.safetensors` | ~41 GB | `ComfyUI/models/diffusion_models/qwen/` | [Comfy-Org/Qwen-Image-Edit_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder | `qwen_2.5_vl_7b.safetensors` | ~17 GB | `ComfyUI/models/text_encoders/qwen/` | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors) |
| Qwen Image VAE | `qwen_image_vae.safetensors` | ~255 MB | `ComfyUI/models/vae/qwen/` | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) |
| Qwen Edit Lightning 4-step BF16 LoRA | `Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors` | 500 MB | `ComfyUI/models/loras/qwen/` | [lightx2v/Qwen-Image-Edit-2511-Lightning](https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors) |
| Qwen Flymy Realism LoRA | `Qwen-flymy_realism.safetensors` | 500 MB | `ComfyUI/models/loras/qwen/` | [flymy-ai/qwen-image-realism-lora](https://huggingface.co/flymy-ai/qwen-image-realism-lora/resolve/main/flymy_realism.safetensors) — **rename to `Qwen-flymy_realism.safetensors` after download** |
| SAM2 Hiera Tiny | `sam2_hiera_tiny.safetensors` | ~150 MB | `ComfyUI/models/sam2/` | [Kijai/sam2-safetensors](https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_tiny.safetensors) |

> The Qwen Image Edit 2511 stack is shared with Modules 03, 04, and Bonus A — download once.
