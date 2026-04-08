<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 04 — Image to Gaussian Splat

## Overview

This workflow uses SHARP, a model capable of inferring molecular-level depth, to generate a 3D Gaussian point cloud from a single image. The result is a navigable 3D representation that lets you explore new angles, depths, and perspectives from what began as a flat 2D reference.

## The Problem It Solves

A single image may capture the right mood, but not the angle or viewpoint you need. Gaussian splatting reconstructs depth and structure, allowing you to explore alternate perspectives faithfully and adding dimensionality to flat references.

## Key Features

- **Gaussian Splatting Integration:** Converts any 2D image into a 3D Gaussian representation.
- **Depth-Aware Reconstruction:** Adds structure and dimensionality to flat images.
- **3D Workflow Compatibility:** Enables mixing 2D references with 3D assets and pipelines.

## How It Works

```
Input -> SHARP -> Gaussian Splat -> 3D Output
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 2 packages |
| **Models** | Bundled with ComfyUI-Sharp |

## Required Models

The SHARP model (`sharp_2572gikvuh.pt`, ~2.81 GB) downloads automatically when the ComfyUI-Sharp node is installed.

## Required Custom Nodes

- [ComfyUI-Sharp](https://github.com/PozzettiAndrea/ComfyUI-Sharp)
- [ComfyUI-GeometryPack](https://github.com/PozzettiAndrea/ComfyUI-GeometryPack)

## Sample Input

A sample input image is provided in the `input/` folder.

## How to Use

1. Load `workflow.json` into ComfyUI
2. Connect your input image and click **Queue Prompt**
