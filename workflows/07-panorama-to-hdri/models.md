# Models — Module 07: Panorama to HDRI

Total storage: ~24.8 GB
VRAM: 16–24 GB (highest of all modules)

> This module uses Flux Dev Kontext — architecturally isolated from the Qwen-based modules. Different base model, different text encoders.

## Base Model

| Model | Size | Source |
|-------|------|--------|
| Flux Dev Kontext FP8 | 11.9 GB | `city96/FLUX.1-dev-gguf` |
| CLIP-L / ViT-L-14 | 250 MB | `comfyanonymous/flux_text_encoders` |
| T5-XXL FP16 | 9.8 GB | `comfyanonymous/flux_text_encoders` |
| Flux VAE (ae.safetensors) | 340 MB | `black-forest-labs/FLUX.1-dev` |

## LoRAs

| Model | Size | Purpose |
|-------|------|---------|
| Flux Turbo LoRA | 500 MB | `jasperai/Flux.1-dev-FastPass` — fast inference |
| EV +4 LoRA | 500 MB | Exposure bracket +4 stops |
| EV +2 LoRA | 500 MB | Exposure bracket +2 stops |
| EV -2 LoRA | 500 MB | Exposure bracket -2 stops |
| EV -4 LoRA | 500 MB | Exposure bracket -4 stops |

The 4 exposure LoRAs are DLI course assets, custom-trained for HDRI generation. Total: 2 GB for the full bracket set.
