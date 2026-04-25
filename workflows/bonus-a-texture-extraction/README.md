<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Bonus A — Texture Extraction
![](images/preview.png)

## Overview

This workflow extracts clean, seamless, flat-world texture maps from any image using community-trained LoRAs, masking and cropping techniques, and LLM-guided refinement. The result is a production-ready texture for use in 3D materials, look-dev, environment building, or asset creation.

## The Problem It Solves

Whether you are recreating a material from a 2D reference, generating supporting textures for background assets, or experimenting with new surface types, the first step is always the same: producing a seamless, high-quality texture. Doing this manually is slow and inconsistent.

## Key Features

- **LoRA-Driven Texture Extraction:** Uses specialized LoRAs to isolate and extract material patterns from an image.
- **Masking and Cropping for Consistency:** Ensures the extracted texture is uniform and clean.
- **Upscaling:** Enhances low-resolution samples into sharp, 4K-ready textures.

## How It Works

```
Image -> VLM -> Segmentation/Masking -> LoRA -> Diffusion Model -> Output Texture
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 4 packages |
| **Models** | 5 files |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `qwen_image_edit_2511_bf16.safetensors` | Image Edit Model | ~41 GB |
| `qwen_2.5_vl_7b.safetensors` | Text Encoder | ~17 GB |
| `qwen_image_vae.safetensors` | VAE | ~255 MB |
| `extract_texture_qwen_image_edit_2509.safetensors` | LoRA | ~500 MB |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | LoRA | ~1.7 GB |

## Required Custom Nodes

- [ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (Sandbox branch)
- [ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use)
- [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes)
- [ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch)

## Sample Input

A sample input image is provided in the `input/` folder.

## How to Use

1. Load `bonus-a-texture-extraction.json` into ComfyUI
2. Connect your input image and click **Queue Prompt**
3. The output texture can be used directly in [Bonus B — Texture to PBR](../bonus-b-texture-to-pbr/)

## Troubleshooting

### Install key for --modules
Use `bonus-a` (not `bonus_a` or `a`). To install both bonus modules: `--modules bonus-a,bonus-b`.

### Texture has visible seams
Increase the overlap/feather setting in the CropAndStitch node. A feather of 32–64 px typically eliminates seams for 1024×1024 textures.

### ComfyUI-TextureAlchemy nodes missing
Must be installed from the Sandbox branch. The install script handles this automatically. If installed manually via Manager, it installs the wrong branch. Re-clone with: `git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy`
