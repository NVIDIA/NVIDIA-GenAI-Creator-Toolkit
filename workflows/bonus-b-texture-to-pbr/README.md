<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Bonus B — Texture to PBR
![](images/preview.png)

## Overview

This workflow turns a single texture into a full PBR material set. Use Lotus to extract Normal, Depth, and Height information, and Marigold Light + Marigold Appearance for Albedo, Roughness, and Metallic maps through intrinsic image decomposition.

## The Problem It Solves

The leading tool for PBR extraction today is Adobe Substance Sampler, but it lacks key outputs like Metallic maps. This workflow offers a generative alternative — a complete set of PBR textures from a single image, with no specialized hardware or manual capture required.

## How It Works

```
Input Texture -> Lotus Depth -> Lotus Height -> Marigold Appearance -> Marigold Lighting -> PBR Outputs
```

## Key Features

- **G-Buffer Map Creation:** Smooth, consistent Depth and Height maps via Lotus.
- **Full PBR Extraction:** Roughness, Metallic, Albedo, and lighting passes via Marigold.
- **Quality Optimization:** Padding, cropping, and adjustment strategies for correct gradient fidelity.

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 3 packages |
| **Models** | 4 files + Marigold (auto-downloaded) |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `lotus-depth-g-v2-1-disparity-fp16.safetensors` | Lotus Depth Model | ~2 GB |
| `lotus-normal-g-v1-0.safetensors` | Lotus Normal Model | ~2 GB |
| `lotus-normal-d-v1-0.safetensors` | Lotus Normal Model | ~2 GB |
| `LotusVAE.safetensors` | VAE | ~300 MB |

> **Note:** Marigold models download automatically from HuggingFace when first used via the ComfyUI-Marigold node.

## Required Custom Nodes

- [ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (Sandbox branch)
- [ComfyUI-Lotus](https://github.com/kijai/ComfyUI-Lotus)
- [ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold)

## Sample Input

A sample input image is provided in the `input/` folder. You can also use output from [Bonus A — Texture Extraction](../bonus-a-texture-extraction/).

## How to Use

1. Load `workflow.json` into ComfyUI
2. Connect your input texture and click **Queue Prompt**
