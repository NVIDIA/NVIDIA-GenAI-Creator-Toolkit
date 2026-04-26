<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 08 — Trellis2 3D Asset Generation

> **Windows only.** Trellis2's CUDA extensions are distributed as pre-built wheels tied to specific PyTorch versions. ABI incompatibilities with current PyTorch releases on Linux prevent the nodes from loading. Linux support depends on upstream wheel updates from the Trellis2 author.
![](images/08-output.gif)

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
| **Models** | 3 files |
| **Disk Space** | ~20 GB |

## Required Models

| Model | Size |
|-------|------|
| `microsoft/TRELLIS.2-4B` | ~16 GB |
| `facebook/dinov3-vitl16-pretrain-lvd1689m` | ~1 GB |
| `microsoft/TRELLIS-image-large` | ~3 GB |

Pre-download before running:

```bash
python download_models.py --comfyui C:\path\to\ComfyUI --modules 08
```

> **DINOv3 is a gated model.** Before running the installer, visit [huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m](https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m), log in, and click **Agree and access repository**. Meta approvals are typically granted within 24–48 hours. The installer will prompt you to confirm before attempting the download.

## Required Custom Nodes

- [ComfyUI-Trellis2](https://github.com/visualbruno/ComfyUI-Trellis2)
- [zsq_prompt](https://github.com/windfancy/zsq_prompt)

## Example Output

| Input Image | Output 3D Model |
|-------------|-----------------|
| ![](images/08-input.png) | ![](images/08-output.gif) |

## Sample Input

A sample input image is provided in the `input/` folder.

## Installation Notes

- **Python version:** Python 3.11 or 3.12 is required. Python 3.13 is missing pre-built wheels for the Trellis2 CUDA extensions and open3d.
- **PyTorch version:** The Trellis2 pre-built CUDA wheels require PyTorch 2.8.x due to C++ ABI compatibility. If a newer version is detected, the installer downgrades automatically. All other modules in this collection work correctly on PyTorch 2.8.0.
- **Windows patches:** The installer automatically patches two upstream compatibility issues — a `transformers` 5+ API change affecting the DINOv3 feature extractor, and a missing `flash_attn` dependency (no pre-built Windows wheel) which falls back to `torch.nn.functional.scaled_dot_product_attention`.

## How to Use

1. Load `08-image-to-3d.json` into ComfyUI
2. Connect your reference image and click **Queue Prompt**

## Troubleshooting

### DINOv3 download fails — access restricted
DINOv3 is a gated model. Visit https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m, log in, and click "Agree and access repository". Meta approvals are typically granted within 24–48 hours. Then re-run the installer.

### Trellis2 nodes fail to load on Linux
Module 08 is Windows only. The Trellis2 CUDA extension wheels (cumesh, nvdiffrast) are pre-built for specific PyTorch ABI versions that conflict with current Linux PyTorch builds. Linux support depends on upstream wheel updates.

### Python version error — open3d not found
Python 3.11 or 3.12 is required. Python 3.13 has no pre-built wheels for open3d or the Trellis2 CUDA extensions. Create a Python 3.11 or 3.12 environment and re-run the installer.

### PyTorch version downgraded after install
Expected. Trellis2 pre-built CUDA wheels require PyTorch 2.8.x due to C++ ABI compatibility. The installer downgrades automatically. All other modules continue to work on PyTorch 2.8.0.

### flash_attn import error
Expected on Windows — no pre-built Windows wheel exists. The installer patches Trellis2 to fall back to `torch.nn.functional.scaled_dot_product_attention` automatically.
