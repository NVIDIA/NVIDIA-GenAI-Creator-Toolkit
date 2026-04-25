<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 04 — Image to Gaussian Splat

> Converts a 2D image into a navigable 3D Gaussian point cloud using SHARP.

→ [Workflow files and usage guide](../workflows/04-image-to-gaussian-splat/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| SHARP (auto-download) | Bundled with ComfyUI-Sharp | — | Node cache directory |

> SHARP is bundled with the ComfyUI-Sharp custom node — no manual model download required. The model downloads automatically when the node is first used.

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-Sharp | https://github.com/PozzettiAndrea/ComfyUI-Sharp | Includes SHARP model (auto-download) |
| ComfyUI-GeometryPack | https://github.com/PozzettiAndrea/ComfyUI-GeometryPack | Gaussian Splat geometry tools |
| ComfyUI-TextureAlchemy (Sandbox branch) | https://github.com/amtarr/ComfyUI-TextureAlchemy | Must be Sandbox branch |

## Troubleshooting

### SHARP model not found on first run
ComfyUI-Sharp downloads SHARP automatically when the workflow runs for the first time. Ensure you have an internet connection. The model caches to the node's directory after download.

### Gaussian Splat viewer not opening
The 3D viewer requires WebGL. Use a Chromium-based browser (Chrome, Edge). Firefox may require enabling WebGL flags.

### Point cloud is noisy / incorrect geometry
SHARP performs best on images with clear subject-background separation. Crop tightly to the subject and avoid complex backgrounds.
