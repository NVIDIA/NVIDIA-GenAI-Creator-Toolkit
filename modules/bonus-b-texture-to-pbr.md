<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module Bonus B — Texture to PBR

> Generates a full PBR material set (Normal, Height, Albedo, Roughness, Metallic) from a single texture using Lotus and Marigold.

→ [Workflow files and usage guide](../workflows/bonus-b-texture-to-pbr/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_edit_2511_bf16.safetensors` | Comfy-Org/Qwen-Image-Edit_ComfyUI | ~41 GB | models/diffusion_models/qwen/ — shared with Bonus A |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~17 GB | models/text_encoders/qwen/ — shared with Bonus A |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ — shared with Bonus A |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | lightx2v/Qwen-Image-Lightning | ~1.7 GB | models/loras/qwen/ — shared with Bonus A |
| `lotus-depth-g-v2-1-disparity-fp16.safetensors` | Kijai/lotus-comfyui | ~2 GB | models/diffusion_models/lotus/ |
| `lotus-normal-g-v1-0.safetensors` | Kijai/lotus-comfyui | ~2 GB | models/diffusion_models/lotus/ |
| `lotus-normal-d-v1-0.safetensors` | Kijai/lotus-comfyui | ~2 GB | models/diffusion_models/lotus/ |
| `LotusVAE.safetensors` (renamed from diffusion_pytorch_model.safetensors) | jingheya/lotus-depth-g-v2-0-disparity | ~300 MB | models/vae/ |
| `4x-UltraSharp.pth` | Kim2091/UltraSharp | ~65 MB | models/upscale_models/ |
| Marigold models (Appearance + Light) | downloaded automatically on first run via ComfyUI-Marigold | — | no manual download required |

> Install key: `bonus-b` — e.g. `install.bat C:\path\to\ComfyUI --modules bonus-b`. To install both bonus modules: `--modules bonus-a,bonus-b`.

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | General utilities |
| ComfyUI-Lotus | https://github.com/kijai/ComfyUI-Lotus | Depth and normal extraction |
| ComfyUI-Marigold | https://github.com/kijai/ComfyUI-Marigold | Albedo / roughness / metallic extraction |

## Troubleshooting

### Install key for --modules
Use `bonus-b` (not `bonus_b` or `b`). To install both bonus modules together: `--modules bonus-a,bonus-b`.

### Marigold models not found on first run
Marigold downloads its models automatically from HuggingFace when first used. Ensure you have an internet connection and run the workflow once — it will download ~2–4 GB and cache locally.

### ComfyUI-Marigold import error / numpy
The installer patches Marigold for numpy 2.0 compatibility. If installed manually via Manager, apply the patch: in `ComfyUI-Marigold/nodes.py`, replace all instances of `.tostring()` with `.tobytes()`.

### Run Bonus A first for best results
Bonus B is designed to work with seamless tiled textures as input. Running Bonus A → Bonus B gives the cleanest PBR results. You can also use any tileable texture image as input.
