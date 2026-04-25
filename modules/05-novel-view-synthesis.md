<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 05 — Novel View Synthesis

> Fills occluded areas in Gaussian Splat output for full camera freedom using Qwen Image Edit 2511.

→ [Workflow files and usage guide](../workflows/05-novel-view-synthesis/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_edit_2511_bf16.safetensors` | Comfy-Org/Qwen-Image-Edit_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~17 GB | models/text_encoders/qwen/ |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | lightx2v/Qwen-Image-Lightning | ~1.7 GB | models/loras/qwen/ |
| `Qwen2511SharpGaussianSplat.safetensors` (renamed from 高斯泼溅-Sharp.safetensors) | dx8152/Qwen-Image-Edit-2511-Gaussian-Splash | ~230 MB | models/loras/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-Sharp | https://github.com/PozzettiAndrea/ComfyUI-Sharp | Gaussian Splat viewer |
| ComfyUI-GeometryPack | https://github.com/PozzettiAndrea/ComfyUI-GeometryPack | Geometry tools |
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |

## Troubleshooting

### Gaussian Splat LoRA not loading
The LoRA file has a Chinese filename in the source repo (`高斯泼溅-Sharp.safetensors`) and is renamed to `Qwen2511SharpGaussianSplat.safetensors` by the downloader. If you downloaded manually, rename the file accordingly.

### Run Module 04 first
This module builds on the Gaussian Splat output from Module 04. Run Module 04 first and use its output as input here.

### Occlusion filling has artifacts
Increase sampler steps or try a different seed. Novel view synthesis is sensitive to the camera angle — stay within ±30° of the original view for best results.
