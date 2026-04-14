# Models — Module 03: Targeted Inpainting

Total storage: ~60 GB
VRAM: 16–24 GB

| Model | File | Size | Destination | Source |
|-------|------|------|-------------|--------|
| Qwen Image Edit 2511 BF16 | `qwen_image_edit_2511_bf16.safetensors` | ~41 GB | `ComfyUI/models/diffusion_models/qwen/` | [Comfy-Org/Qwen-Image-Edit_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder (FP8) | `qwen_2.5_vl_7b_fp8_scaled.safetensors` | ~17 GB | `ComfyUI/models/text_encoders/qwen/` | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors) |
| Qwen Image VAE | `qwen_image_vae.safetensors` | ~255 MB | `ComfyUI/models/vae/qwen/` | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) |
| Qwen Lightning 8-step LoRA | `Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors` | ~1.7 GB | `ComfyUI/models/loras/qwen/` | [lightx2v/Qwen-Image-Lightning](https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors) |

> The Qwen Image Edit 2511 stack (diffusion model + text encoder + VAE + Lightning LoRA) is shared with Modules 05, 06, Bonus A, and Bonus B.
