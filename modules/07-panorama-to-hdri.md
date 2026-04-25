<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 07 — Panorama to HDRI

> Converts a panoramic equirectangular image into a production-ready HDRI for 3D engine lighting using Flux Dev Kontext and exposure LoRAs.

→ [Workflow files and usage guide](../workflows/07-panorama-to-hdri/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `flux1-dev-kontext_fp8_scaled.safetensors` | Comfy-Org/flux1-kontext-dev_ComfyUI | 11.9 GB | models/diffusion_models/flux/ |
| `ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors` | zer0int/CLIP-GmP-ViT-L-14 | ~900 MB | models/text_encoders/flux/ |
| `t5xxl_fp16.safetensors` | comfyanonymous/flux_text_encoders | 9.8 GB | models/text_encoders/flux/ |
| `ae.safetensors` | black-forest-labs/FLUX.1-dev | 340 MB | models/vae/flux/ |
| `Flux1DevTurbo.safetensors` (renamed from flux.2-turbo-lora.safetensors) | fal/FLUX.2-dev-Turbo | ~500 MB | models/loras/flux/ |
| `evminus4.safetensors` | Sumitc13/Flux-Kontext-exposure-control-LoRAs | ~330 MB | models/loras/flux/ |
| `evminus2.safetensors` | Sumitc13/Flux-Kontext-exposure-control-LoRAs | ~330 MB | models/loras/flux/ |
| `evplus2.safetensors` | Sumitc13/Flux-Kontext-exposure-control-LoRAs | ~330 MB | models/loras/flux/ |
| `evplus4.safetensors` | Sumitc13/Flux-Kontext-exposure-control-LoRAs | ~330 MB | models/loras/flux/ |

> `ae.safetensors` is a GATED model: requires HuggingFace login and acceptance of the Black Forest Labs license at https://huggingface.co/black-forest-labs/FLUX.1-dev

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |
| ComfyUI-WJNodes | https://github.com/807502278/ComfyUI-WJNodes | General utilities |
| ComfyUI-Marigold | https://github.com/kijai/ComfyUI-Marigold | Exposure processing |
| Luminance-Stack-Processor | https://github.com/sumitchatterjee13/Luminance-Stack-Processor | HDR assembly |

## Troubleshooting

### Flux VAE download fails with 401/403
The Flux VAE (`ae.safetensors`) is gated. Run `huggingface-cli login` and accept the Black Forest Labs license at https://huggingface.co/black-forest-labs/FLUX.1-dev before re-running the installer.

### ComfyUI-Marigold import error / numpy
The installer patches Marigold for numpy 2.0 compatibility automatically. If you installed Marigold manually via Manager, apply the patch: in `ComfyUI-Marigold/nodes.py`, replace `.tostring()` with `.tobytes()`.

### Run Module 06 first
This module expects a panoramic equirectangular image as input. Run Module 06 to generate one, or use your own 2:1 aspect ratio panorama.
