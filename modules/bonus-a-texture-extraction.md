<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module Bonus A — Texture Extraction

> Extracts seamless tileable textures from any image using Qwen Image Edit 2511 and a texture-specific LoRA.

→ [Workflow files and usage guide](../workflows/bonus-a-texture-extraction/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_edit_2511_bf16.safetensors` | Comfy-Org/Qwen-Image-Edit_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~17 GB | models/text_encoders/qwen/ |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | lightx2v/Qwen-Image-Lightning | ~1.7 GB | models/loras/qwen/ |
| `extract_texture_qwen_image_edit_2509.safetensors` | tarn59/extract_texture_qwen_image_edit_2509 | ~500 MB | models/loras/qwen/ |

> Install key: `bonus-a` — e.g. `install.bat C:\path\to\ComfyUI --modules bonus-a` or `bash install.sh /path/to/ComfyUI --modules bonus-a`. To install both bonus modules: `--modules bonus-a,bonus-b`.

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | General utilities |
| ComfyUI-Inpaint-CropAndStitch | https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch | Seam handling |
| ComfyUI-KJNodes | https://github.com/kijai/ComfyUI-KJNodes | Masking utilities |

## Troubleshooting

### Install key for --modules
Use `bonus-a` (not `bonus_a` or `a`). Example: `install.bat C:\path\to\ComfyUI --modules bonus-a` or `bash install.sh /path/to/ComfyUI --modules bonus-a`. To install both bonus modules: `--modules bonus-a,bonus-b`.

### Texture has visible seams
Increase the overlap/feather setting in the CropAndStitch node. A feather of 32–64 px typically eliminates seams for 1024×1024 textures.

### ComfyUI-TextureAlchemy nodes missing
Must be installed from the Sandbox branch. The install script handles this automatically. If installed manually via Manager, it installs the wrong branch. Re-clone with: `git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy`
