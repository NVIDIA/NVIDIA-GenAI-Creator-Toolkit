# Models — Module 07: Panorama to HDRI

Total storage: ~24.8 GB
VRAM: 16–24 GB (highest of all modules)

> This module uses Flux Dev Kontext — architecturally isolated from the Qwen-based modules. Different base model, different text encoders.

> **License notice:** Flux.1-dev is subject to the [Black Forest Labs Flux.1-dev Non-Commercial License](https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/LICENSE.md). Review before any commercial use.

## Base Model

| Model | File | Size | Destination | Source |
|-------|------|------|-------------|--------|
| Flux Dev Kontext FP8 | `flux1-dev-kontext_fp8_scaled.safetensors` | 11.9 GB | `ComfyUI/models/diffusion_models/` | [Comfy-Org/flux1-kontext-dev_ComfyUI](https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors) |
| CLIP-L / ViT-L-14 | `ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors` | 250 MB | `ComfyUI/models/text_encoders/` | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors) |
| T5-XXL FP16 | `t5xxl_fp16.safetensors` | 9.8 GB | `ComfyUI/models/text_encoders/` | [comfyanonymous/flux_text_encoders](https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors) |
| Flux VAE | `ae.safetensors` | 340 MB | `ComfyUI/models/vae/` | [black-forest-labs/FLUX.1-dev](https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors) |

## LoRAs

Place in `ComfyUI/models/loras/`

| Model | File | Size | Source | Purpose |
|-------|------|------|--------|---------|
| Flux Turbo LoRA | `Flux1DevTurbo.safetensors` | ~500 MB | [fal/FLUX.2-dev-Turbo](https://huggingface.co/fal/FLUX.2-dev-Turbo) | Fast inference |
| EV +4 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket +4 stops |
| EV +2 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket +2 stops |
| EV -2 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket -2 stops |
| EV -4 LoRA | *(DLI course asset)* | 500 MB | See note below | Exposure bracket -4 stops |

The 4 exposure LoRAs are custom-trained for HDRI generation. Total: 2 GB for the full bracket set.

> **EV LoRA access:** These LoRAs are currently distributed through the NVIDIA DLI course [DLIT81948](https://www.nvidia.com/en-us/training/). If you have not taken the course, enroll to access the lab environment where these assets are available. Public release of these LoRAs is pending. Watch this repo for updates.

## Download Commands

Run from the parent directory of your ComfyUI install (the folder containing `ComfyUI/`):

```bash
# Flux Dev Kontext FP8 diffusion model
hf download Comfy-Org/flux1-kontext-dev_ComfyUI \
  split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors \
  --local-dir ComfyUI/models/diffusion_models

# Text encoders
hf download comfyanonymous/flux_text_encoders \
  ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors \
  t5xxl_fp16.safetensors \
  --local-dir ComfyUI/models/text_encoders

# Flux VAE (requires HuggingFace login — run: hf login)
hf download black-forest-labs/FLUX.1-dev ae.safetensors \
  --local-dir ComfyUI/models/vae
```

> The `hf download` command places files in a subdirectory matching the repo path. After downloading the diffusion model, move `flux1-dev-kontext_fp8_scaled.safetensors` out of `split_files/diffusion_models/` directly into `ComfyUI/models/diffusion_models/`.
