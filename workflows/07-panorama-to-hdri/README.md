<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 07 — Panorama to HDRI
![](images/preview.png)

## Overview

This workflow converts a panoramic equirectangular image into a true HDRI for lighting in 3D engines, VFX, and PBR workflows. We generate multiple exposure stops using a curated library of LoRAs, then combine them using a custom luminance-stacking node system to produce an HDR environment map ready for use as an IBL in Unreal, Cycles, V-Ray, Arnold, and more.

## The Problem It Solves

Creating a real HDRI traditionally requires specialized equipment — a mirror ball, a professional camera capable of bracketed exposures, and a physical environment to capture. This workflow offers a fast alternative: generate exposure-bracketed panoramas from a single image and assemble them into a production-ready HDRI.

## Key Features

- **Multi-LoRA Branching:** Uses several LoRAs to generate reliable exposure stops.
- **HDR Assembly Pipeline:** Stacks multiple AI-generated exposures into a single HDRI.
- **Production-Ready Output:** Suitable for lighting in any major 3D engine.

## How It Works

```
Panoramic Image -> Four LoRAs -> Four Exposure Passes -> Luminance Stack -> HDRI (IBL)
```

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM (Minimum)** | 16 GB |
| **VRAM (Recommended)** | 24 GB |
| **Custom Nodes** | 4 packages |
| **Models** | 6 files + 4 gated LoRAs |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `flux1-dev-kontext_fp8_scaled.safetensors` | Image Model | 11.09 GB |
| `flux1-dev-kontext.safetensors` | Image Model | — |
| `ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors` | Text Encoder | 888 MB |
| `t5xxl_fp16.safetensors` | Text Encoder | 9.12 GB |
| `ae.safetensors` | VAE | ~340 MB |
| `Flux1DevTurbo.safetensors` | LoRA | ~500 MB |
| `evminus4.safetensors` | LoRA (DLI course asset) | 328 MB |
| `evminus2.safetensors` | LoRA (DLI course asset) | 328 MB |
| `evplus2.safetensors` | LoRA (DLI course asset) | 328 MB |
| `evplus4.safetensors` | LoRA (DLI course asset) | 328 MB |

> **Note:** The EV LoRAs are DLI course assets. Enroll in [NVIDIA DLI course DLIT81948](https://www.nvidia.com/en-us/on-demand/session/gtc26-dlit81948/) to access them.
>
> **Note:** Flux.1-dev requires a HuggingFace login and acceptance of the [Black Forest Labs license](https://huggingface.co/black-forest-labs/FLUX.1-dev) for commercial use.

## Required Custom Nodes

- [ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (Sandbox branch)
- [ComfyUI-WJNodes](https://github.com/807502278/ComfyUI-WJNodes)
- [ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold)
- [Luminance-Stack-Processor](https://github.com/sumitchatterjee13/Luminance-Stack-Processor)

## Example Output

| Input Panorama | EV-4 | EV-2 | EV+2 | EV+4 |
|----------------|------|------|------|------|
| ![](images/07-input.png) | ![](images/07-output-ev1.png) | ![](images/07-output-ev2.png) | ![](images/07-output-ev3.png) | ![](images/07-output-ev4.png) |

## Sample Input

Run [Module 06](../06-equirectangular-outpainting/) first to generate a panorama, or use a sample from `input/`.

## How to Use

1. Complete [Module 06](../06-equirectangular-outpainting/) to generate your panorama
2. Load `workflow.json` into ComfyUI
3. Connect your panorama and click **Queue Prompt**
