<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 09 — Cutout Animation to Video
![](images/preview.gif)

## Overview

This workflow generates trajectory-controlled video from image inputs using Wan2.2 Image-to-Video. Define exactly when and where motion happens by providing first and last frames along with a mask, giving you precise control over the animation path and timing.

## Key Features

- **Trajectory Control:** Define motion start and end frames explicitly.
- **Multi-Model Integration:** Leverages Wan2.2 I2V models for high- and low-noise generation.
- **LoRA Fine-tuning:** Stylistic control and targeted refinement.

## How It Works

```
First Frame + Last Frame + Mask -> VideoPrep -> Wan2.2 I2V -> Video Output
```

## Two Workflows

This module includes two workflow files:

1. **`09-image-cut-out-time-to-move-videoprep.json`** — Run this first. Prepares your input images and mask.
2. **`09-image-cut-out-time-to-move.json`** — The main video generation workflow.

## How to Use

1. Open `09-image-cut-out-time-to-move-videoprep` from the ComfyUI Template Browswer or Workflow Browser and run it to prepare your inputs
2. Click **Run**
3. Open `09-image-cut-out-time-to-move` from the ComfyUI Template Browswer or Workflow Browser
4. Connect your prepared inputs and click **Run**
   
## Sample Input

Sample input frames, video, and mask are provided in the `input/` folder.

## Example Output
<video src="images/09-output.mp4" autoplay loop muted playsinline width="100%"></video>

## ComfyUI Canvas

**VideoPrep workflow:**
![Module 09 VideoPrep node graph](../../docs/comfyui_workflow_09_videoprep.png)

**Main workflow:**
![Module 09 node graph](../../docs/comfyui_workflow_09.png)  
Green box indicates a prompt box.

## Requirements

| Requirement | Value |
|-------------|-------|
| **VRAM Min. Rec. Windows** | 32 GB |
| **VRAM Min. Rec. Linux** | 48 GB |
| **Custom Nodes** | 7 packages |
| **Models** | 12 files |
| **Disk Space** | ~77 GB |

## Required Models

| Model | Type | Size |
|-------|------|------|
| `Wan2_2-I2V-A14B-HIGH_bf16.safetensors` | Diffusion Model | ~28 GB |
| `Wan2_2-I2V-A14B-LOW_bf16.safetensors` | Diffusion Model | ~28 GB |
| `wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step.safetensors` | LoRA | ~1 GB |
| `umt5_xxl_fp16.safetensors` | Text Encoder | ~11 GB |
| `sam3.pt` | Segmentation Model | ~3.4 GB |
| `wan_2.1_vae.safetensors` | VAE | ~250 MB |
| `Wan22_PusaV1_lora_HIGH_resized_dynamic_avg_rank_98_bf16.safetensors` | LoRA | ~950 MB |
| `Wan22_PusaV1_lora_LOW_resized_dynamic_avg_rank_98_bf16.safetensors` | LoRA | ~970 MB |
| `Wan2.2-Fun-A14B-InP-high-noise-HPS2.1.safetensors` | LoRA | ~860 MB |
| `Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors` | LoRA | ~860 MB |
| `Wan22_A14B_T2V_LOW_Lightning_4steps_lora_rank64_fp16.safetensors` | LoRA | ~615 MB |
| `Qwen-flymy_realism.safetensors` | LoRA | ~500 MB |

## Required Custom Nodes

- [ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper)
- [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes)
- [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite)
- [ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts)
- [ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use)
- [ComfyUI_essentials](https://github.com/cubiq/ComfyUI_essentials)
- [ComfyUI-Impact-Pack](https://github.com/ltdrdata/ComfyUI-Impact-Pack)

## Troubleshooting

### Two workflows — run VideoPrep first
This module requires two workflows in sequence. Run `09-image-cut-out-time-to-move-videoprep.json` first to prepare your first frame, last frame, and mask. Then run `09-image-cut-out-time-to-move.json` for video generation. Skipping VideoPrep causes the main workflow to finish in under 1 second with no output.

### Job finishes in under 1 second with no output
The video input nodes are empty. Load the VideoPrep outputs (first frame image, last frame image, mask image, and reference video) into the corresponding Load Image / Load Video nodes before queuing. The video loader shows only small red text when empty — easy to miss.

### ComfyUI-Impact-Pack shows IMPORT FAILED
Impact Pack requires `ultralytics` and `onnxruntime`. On ComfyUI Portable, install manually: `python_embeded\python.exe -m pip install ultralytics onnxruntime`. If `onnxruntime` conflicts with `onnxruntime-gpu`, use: `python_embeded\python.exe -m pip install ultralytics onnxruntime-gpu`. Then restart ComfyUI.

### TritonMissing error during generation
Triton is not available in ComfyUI Portable's embedded Python on Windows. In the `WanVideoSampler` node, set `torch_compile_args` to disabled/off. Generation speed is unaffected for most GPUs.

### Generation is very slow on 16 GB VRAM
Enable FP8 quantization and KJNodes block-swap in the workflow. Keep sequences under 24 frames at 480p. 24 GB VRAM is recommended for practical use.
