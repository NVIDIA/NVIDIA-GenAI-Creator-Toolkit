<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 08 — Trellis2 3D Asset Generation
![](images/preview.png)

## Overview

This workflow converts image references into usable 3D assets with PBR materials using Trellis2. Generated assets work well as starting meshes, stand-ins for previs, or structural anchors for reframing — especially when combined with Module 04 (Image to Gaussian Splat).

## Key Features

- **Image-to-3D Conversion:** Optimal settings for generating textured 3D assets from a single reference image.
- **PBR-Ready Output:** Produces models with materials suitable for modern rendering pipelines.
- **Flexible Use Cases:** Ideal for previs, layout, blocking, or as geometry foundations for further generative workflows.

## How It Works

```
Image -> Trellis2 -> 3D Model with PBR Materials
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 2 packages |
| **Models** | Bundled with ComfyUI-TRELLIS2 |

## Required Models

The Trellis2 model (~16.2 GB) downloads automatically when the ComfyUI-TRELLIS2 node is installed.

## Required Custom Nodes

- [ComfyUI-TRELLIS2](https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2)
- [zsq_prompt](https://github.com/windfancy/zsq_prompt)

## Sample Input

A sample input image is provided in the `input/` folder.

## How to Use

1. Load `workflow.json` into ComfyUI
2. Connect your reference image and click **Queue Prompt**
