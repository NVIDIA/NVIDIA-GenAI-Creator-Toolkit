# Models — Module 09: Cutout Animation to Video (Wan TTM)

Pre-download strongly recommended — Wan2.2 is large.

VRAM: 16–24 GB
Platform: Windows x86_64 and Linux x86_64 only

## Wan2.2 (TTM video generation)

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 I2V 480P | ~28 GB | `Wan-AI/Wan2.2-I2V-14B-480P` |
| UMT5-XXL (text encoder) | ~10 GB | bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | bundled with Wan2.2 |

```bash
huggingface-cli download Wan-AI/Wan2.2-I2V-14B-480P --local-dir ComfyUI/models/video/wan
```

## VideoPrep models (prerequisite)

| Model | File | Size | Source |
|-------|------|------|--------|
| Qwen Image Edit 2511 BF16 | `qwen_image_edit_2511_bf16.safetensors` | 13.5 GB | [Comfy-Org/Qwen-Image-Edit_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder | `qwen_2.5_vl_7b.safetensors` | 14.5 GB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors) |
| Qwen Image VAE | `qwen_image_vae.safetensors` | 170 MB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) |
| Qwen Edit Lightning 4-step BF16 LoRA | `Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors` | 500 MB | [lightx2v/Qwen-Image-Edit-2511-Lightning](https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors) |
| Qwen Flymy Realism LoRA | `Qwen-flymy_realism.safetensors` | 500 MB | [flymy-ai/qwen-image-realism-lora](https://huggingface.co/flymy-ai/qwen-image-realism-lora/resolve/main/flymy_realism.safetensors) |
| SAM2 Hiera Tiny | `sam2_hiera_tiny.safetensors` | ~150 MB | [Kijai/sam2-safetensors](https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2_hiera_tiny.safetensors) |

> The Qwen Image Edit 2511 stack is shared with Modules 03, 05, 06, and Bonus A — download once.
