<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 02 — Image Deconstruction

> Splits any image into foreground, midground, and background layers using Qwen Image Layered.

→ [Workflow files and usage guide](../workflows/02-image-deconstruction/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_layered_bf16.safetensors` | Comfy-Org/Qwen-Image-Layered_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/HunyuanVideo_1.5_repackaged | ~17 GB | models/text_encoders/qwen/ |
| `qwen_2.5_vl_7b_fp8_scaled.safetensors` | Comfy-Org/HunyuanVideo_1.5_repackaged | ~9 GB | models/text_encoders/qwen/ |
| `qwen_image_layered_vae.safetensors` | Comfy-Org/Qwen-Image-Layered_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors` | lightx2v/Qwen-Image-Edit-2511-Lightning | ~810 MB | models/loras/qwen/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-WJNodes | https://github.com/807502278/ComfyUI-WJNodes | Qwen utilities |
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | Qwen utilities |
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |

## Troubleshooting

### ComfyUI-TextureAlchemy nodes missing
This node must be installed from the **Sandbox** branch, not main. The install script handles this automatically. If installed manually via Manager, clone with `--branch Sandbox`. Re-install from the correct branch if nodes show as red.

### Output layers look wrong / all black
Ensure FP8 text encoder is loaded when running on 16 GB VRAM. The BF16 encoder requires 24 GB.
