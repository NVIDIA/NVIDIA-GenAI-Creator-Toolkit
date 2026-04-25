<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 03 — Targeted Inpainting

> Mask-and-patch editing — change only the pixels you select using Qwen Image Edit 2511.

→ [Workflow files and usage guide](../workflows/03-targeted-inpainting/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_edit_2511_bf16.safetensors` | Comfy-Org/Qwen-Image-Edit_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b_fp8_scaled.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~9 GB | models/text_encoders/qwen/ |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors` | lightx2v/Qwen-Image-Lightning | ~1.7 GB | models/loras/qwen/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |
| ComfyUI-Inpaint-CropAndStitch | https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch | Inpainting helper |

## Troubleshooting

### Inpainting bleeds outside the mask
Increase mask feather or padding in the CropAndStitch node settings. A small feather (4–8 px) typically produces clean edges.

### ComfyUI-TextureAlchemy nodes missing
Must be the Sandbox branch. See Module 02 troubleshooting.

### Result looks unchanged
Make sure the mask is correctly connected to the inpainting node and the mask is non-zero (white = area to change, black = preserve).
