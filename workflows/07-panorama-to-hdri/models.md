# Models — Module 07: Panorama to HDRI

Total storage: ~24.8 GB
VRAM: 16–24 GB (highest of all modules)

> This module uses Flux Dev Kontext — architecturally isolated from the Qwen-based modules. Different base model, different text encoders.

> **License notice:** Flux.1-dev is subject to the [Black Forest Labs Flux.1-dev Non-Commercial License](https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/LICENSE.md). Review before any commercial use.

## Base Model

| Model | File | Size | Destination | Source |
|-------|------|------|-------------|--------|
| Flux Dev Kontext FP8 | `flux1-dev-kontext_fp8_scaled.safetensors` | 11.9 GB | `ComfyUI/models/diffusion_models/` | [city96/FLUX.1-dev-gguf](https://huggingface.co/city96/FLUX.1-dev-gguf) |
| CLIP-L / ViT-L-14 | `ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors` | 250 MB | `ComfyUI/models/text_encoders/` | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors) |
| T5-XXL FP16 | `t5xxl_fp16.safetensors` | 9.8 GB | `ComfyUI/models/text_encoders/` | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors) |
| Flux VAE | `ae.safetensors` | 340 MB | `ComfyUI/models/vae/` | [black-forest-labs/FLUX.1-dev](https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors) |

## LoRAs

Place in `ComfyUI/models/loras/`

| Model | File | Size | Source | Purpose |
|-------|------|------|--------|---------|
| Flux Turbo LoRA | `Flux1DevTurbo.safetensors` | 500 MB | [jasperai/Flux.1-dev-FastPass](https://huggingface.co/jasperai/Flux.1-dev-FastPass) | Fast inference |
| EV +4 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket +4 stops |
| EV +2 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket +2 stops |
| EV -2 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket -2 stops |
| EV -4 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket -4 stops |

The 4 exposure LoRAs are custom-trained for HDRI generation. Total: 2 GB for the full bracket set.

> **EV LoRA access:** These LoRAs are currently distributed through the NVIDIA DLI course [DLIT81948](https://www.nvidia.com/en-us/training/). If you have not taken the course, enroll to access the lab environment where these assets are available. Public release of these LoRAs is pending. Watch this repo for updates.
