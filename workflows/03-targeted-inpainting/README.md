<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 03 — Targeted Inpainting
![](images/preview.png)

## Overview

Inpainting lets you modify a scene by masking an area and replacing it with new content. While modern text-to-image edit models offer powerful semantic editing, they often alter the entire image even when you only want a small change. This workflow solves that by using a targeted inpaint-patch system that updates only the selected pixels, blending seamlessly back into the original image for production-ready results.

## The Problem It Solves

- **Traditional inpainting provides limited pixel control, often reducing detail.**
- **Text-based image editing can unintentionally shift or alter surrounding areas.**
- **A mask-and-patch approach gives precise control over what changes.**

## Key Features

- **Targeted Inpainting:** Edits only the defined region for maximum accuracy.
- **Cropping and Stitching:** Handles boundaries cleanly and prevents edge artifacts.
- **Qwen-Powered Reconstruction:** Uses Qwen's editing capabilities for clean object removal and seamless fill.

## Going Further

When paired with Qwen Image Edit 2511, this workflow gives precise control over where new objects appear — ideal for set-building, interior design, object placement, and seamless multi-item composition.

## How It Works

```
Input Image -> Mask -> Model Conditioning -> Diffusion -> Output Image
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 1 package |
| **Models** | 5 files |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `qwen_image_edit_2511_bf16.safetensors` | Image Edit Model | 38.05 GB |
| `qwen_2.5_vl_7b.safetensors` | Text Encoder | 15.45 GB |
| `qwen_image_vae.safetensors` | VAE | 242 MB |
| `Qwen-Image-Lightning-8steps-V2.0.safetensors` | LoRA | 1.58 GB |
| `Qwen-Image-Edit-2511-Object-Remover.safetensors` | LoRA | 225 MB |

## Required Custom Nodes

- [ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch)

## Sample Input

A sample input image is provided in the `input/` folder.

## How to Use

1. Load `workflow.json` into ComfyUI
2. Draw a mask over the area to edit and click **Queue Prompt**
