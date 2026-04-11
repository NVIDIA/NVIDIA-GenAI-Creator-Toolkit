# Models — Module 02: Image Deconstruction

Total storage: ~21.5 GB
VRAM: 10–14 GB

| Model | File | Size | Destination | Source |
|-------|------|------|-------------|--------|
| Qwen Image Layered BF16 | `qwen_image_layered_bf16.safetensors` | ~41 GB | `ComfyUI/models/diffusion_models/qwen/` | [Comfy-Org/Qwen-Image-Layered_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Layered_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_layered_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder | `qwen_2.5_vl_7b.safetensors` | ~17 GB | `ComfyUI/models/text_encoders/qwen/` | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors) |
| Qwen Image Layered VAE | `qwen_image_layered_vae.safetensors` | ~255 MB | `ComfyUI/models/vae/qwen/` | [Comfy-Org/Qwen-Image-Layered_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Layered_ComfyUI/resolve/main/split_files/vae/qwen_image_layered_vae.safetensors) |
| Qwen Lightning 8-step LoRA | `Qwen-Image-Lightning-8steps-V2.0.safetensors` | 500 MB | `ComfyUI/models/loras/qwen/` | [lightx2v/Qwen-Image-Lightning](https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V2.0.safetensors) |

> Module 02 uses the `Qwen Image Layered` variant — a distinct model from the `Qwen Image Edit 2511` used in Modules 03–06. The text encoder is shared across most Qwen modules.
