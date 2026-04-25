<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 08 — Image to 3D

> Converts a 2D reference image into a textured 3D model with PBR materials using Trellis2.

→ [Workflow files and usage guide](../workflows/08-image-to-3d/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `microsoft/TRELLIS.2-4B` (full repo) | microsoft/TRELLIS.2-4B | ~16 GB | models/microsoft/TRELLIS.2-4B/ |
| `facebook/dinov3-vitl16-pretrain-lvd1689m` (full repo) | facebook/dinov3-vitl16-pretrain-lvd1689m | ~1 GB | models/facebook/dinov3-vitl16-pretrain-lvd1689m/ |
| `microsoft/TRELLIS-image-large` (full repo) | microsoft/TRELLIS-image-large | ~3 GB | models/microsoft/TRELLIS-image-large/ |

> `facebook/dinov3-vitl16-pretrain-lvd1689m` is a GATED model: requires HuggingFace login and acceptance of Meta's data agreement at https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-Trellis2 | https://github.com/visualbruno/ComfyUI-Trellis2 | Includes pre-built CUDA wheels for Windows |
| zsq_prompt | https://github.com/windfancy/zsq_prompt | Prompt utilities |

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
