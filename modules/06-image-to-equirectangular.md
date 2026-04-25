<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 06 — Image to Equirectangular

> Turns a single image into a seamless 360° panorama using Qwen Image Edit 2511 and MikMumpitz 360 LoRA.

→ [Workflow files and usage guide](../workflows/06-image-to-equirectangular/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_edit_2511_bf16.safetensors` | Comfy-Org/Qwen-Image-Edit_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~17 GB | models/text_encoders/qwen/ |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | lightx2v/Qwen-Image-Lightning | ~1.7 GB | models/loras/qwen/ |
| `Qwen-Image-Edit-2511-Object-Remover.safetensors` | prithivMLmods/Qwen-Image-Edit-2511-Object-Remover | ~230 MB | models/loras/qwen/ |
| `MikMumpitz360.safetensors` (renamed from 251018_MICKMUMPITZ_QWEN-EDIT_360_03.safetensors) | TheMindExpansionNetwork/special-loras | ~280 MB | models/loras/qwen/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | General utilities |
| ComfyUI-Inpaint-CropAndStitch | https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch | Seam handling |
| ComfyUI-KJNodes | https://github.com/kijai/ComfyUI-KJNodes | Masking and utility nodes |
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |

## Troubleshooting

### Seam visible in panorama
Use the CropAndStitch node's feather setting to soften the join. A seam feather of 32–64 px typically eliminates the seam at standard panorama widths.

### Left/right edges don't align
The panorama outpainting requires the input image to be cropped to a 2:1 aspect ratio. Adjust the crop in the workflow before running.

### Object Remover LoRA not loading
Check that `Qwen-Image-Edit-2511-Object-Remover.safetensors` exists in `models/loras/qwen/`. Re-run `install.bat / install.sh --modules 06` to re-download.
