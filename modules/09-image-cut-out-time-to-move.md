<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 09 — Image Cut Out: Time to Move

> Generates trajectory-controlled video from image inputs using Wan2.2 Image-to-Video — define exactly when and where motion happens using first frame, last frame, and a mask.

→ [Workflow files and usage guide](../workflows/09-image-cut-out-time-to-move/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `wan_2.1_vae.safetensors` | Comfy-Org/Wan_2.1_ComfyUI_repackaged | ~250 MB | models/vae/ |
| `umt5_xxl_fp16.safetensors` | Comfy-Org/Wan_2.1_ComfyUI_repackaged | ~11 GB | models/text_encoders/ |
| `Wan2_2-I2V-A14B-HIGH_bf16.safetensors` | Kijai/WanVideo_comfy | ~28 GB | models/diffusion_models/ |
| `Wan2_2-I2V-A14B-LOW_bf16.safetensors` | Kijai/WanVideo_comfy | ~28 GB | models/diffusion_models/ |
| `Wan22_PusaV1_lora_HIGH_resized_dynamic_avg_rank_98_bf16.safetensors` | Kijai/WanVideo_comfy | ~950 MB | models/loras/ |
| `Wan22_PusaV1_lora_LOW_resized_dynamic_avg_rank_98_bf16.safetensors` | Kijai/WanVideo_comfy | ~970 MB | models/loras/ |
| `Wan2.2-Fun-A14B-InP-high-noise-HPS2.1.safetensors` | alibaba-pai/Wan2.2-Fun-Reward-LoRAs | ~860 MB | models/loras/ |
| `Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors` | alibaba-pai/Wan2.2-Fun-Reward-LoRAs | ~860 MB | models/loras/ |
| `wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step.safetensors` (renamed) | lightx2v/Wan2.2-Distill-Models | ~29 GB | models/loras/ |
| `Wan22_A14B_T2V_LOW_Lightning_4steps_lora_250928_rank64_fp16.safetensors` | Kijai/WanVideo_comfy | ~615 MB | models/loras/ |
| `sam3.pt` | 1038lab/sam3 | ~3.4 GB | models/sam3/ |
| `Qwen-flymy_realism.safetensors` (renamed) | flymy-ai/qwen-image-realism-lora | ~500 MB | models/loras/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| comfy_nv_video_prep | https://github.com/NVIDIA/comfy_nv_video_prep | VideoPrep workflow helper |
| ComfyUI-WanVideoWrapper | https://github.com/kijai/ComfyUI-WanVideoWrapper | Wan2.2 sampler |
| ComfyUI-KJNodes | https://github.com/kijai/ComfyUI-KJNodes | Block swap / masking |
| ComfyUI-VideoHelperSuite | https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite | Video I/O |
| ComfyUI-Custom-Scripts | https://github.com/pythongosssss/ComfyUI-Custom-Scripts | UI utilities |
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | General utilities |
| ComfyUI_essentials | https://github.com/cubiq/ComfyUI_essentials | Image utilities |
| ComfyUI-Impact-Pack | https://github.com/ltdrdata/ComfyUI-Impact-Pack | Segmentation |
| ComfyUI-SAM3 | https://github.com/PozzettiAndrea/ComfyUI-SAM3 | SAM3 segmentation |

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
