<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 10 — Video to Video

> Transforms a basic 3D render into stylized video using Wan2.2 VACE — depth and edges extracted automatically from your render passes to lock structure and motion.

→ [Workflow files and usage guide](../workflows/10-video-to-video/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `wan_2.1_vae.safetensors` | Comfy-Org/Wan_2.1_ComfyUI_repackaged | ~250 MB | models/vae/ |
| `umt5_xxl_fp16.safetensors` | Comfy-Org/Wan_2.1_ComfyUI_repackaged | ~11 GB | models/text_encoders/ |
| `wan2.2_t2v_high_noise_14B_fp16.safetensors` | Comfy-Org/Wan_2.2_ComfyUI_Repackaged | ~28 GB | models/diffusion_models/ |
| `wan2.2_t2v_low_noise_14B_fp16.safetensors` | Comfy-Org/Wan_2.2_ComfyUI_Repackaged | ~28 GB | models/diffusion_models/ |
| `Wan2.2-VACE-Fun-A14B_high_noise_model.safetensors` (renamed) | alibaba-pai/Wan2.2-VACE-Fun-A14B | ~37 GB | models/diffusion_models/ |
| `Wan2.2-VACE-Fun-A14B_low_noise_model.safetensors` (renamed) | alibaba-pai/Wan2.2-VACE-Fun-A14B | ~37 GB | models/diffusion_models/ |
| `lotus-depth-d-v-1-1-fp16.safetensors` | Kijai/lotus-comfyui | ~1.7 GB | models/diffusion_models/ |
| `vae-ft-mse-840000-ema-pruned.safetensors` | stabilityai/sd-vae-ft-mse-original | ~335 MB | models/vae/ |
| `Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors` | Kijai/WanVideo_comfy | ~315 MB | models/loras/ |
| `4x-ClearRealityV1.pth` | skbhadra/ClearRealityV1 | ~9 MB | models/upscale_models/ |

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-WanVideoWrapper | https://github.com/kijai/ComfyUI-WanVideoWrapper | Wan2.2 sampler |
| ComfyUI-Lotus | https://github.com/kijai/ComfyUI-Lotus | Depth extraction |
| ComfyUI-KJNodes | https://github.com/kijai/ComfyUI-KJNodes | Utilities |
| ComfyUI-Custom-Scripts | https://github.com/pythongosssss/ComfyUI-Custom-Scripts | UI utilities |
| ComfyUI-VideoHelperSuite | https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite | Video I/O |
| comfyui-post-processing-nodes | https://github.com/EllangoK/ComfyUI-post-processing-nodes | Post effects |
| cg-use-everywhere | https://github.com/chrisgoringe/cg-use-everywhere | Node wiring helper |
| radiance | https://github.com/fxtdstudios/radiance | Lighting effects |
| comfyui-rtx-simple | https://github.com/BetaDoggo/comfyui-rtx-simple | RTX utilities |
| ComfyUI-Impact-Pack | https://github.com/ltdrdata/ComfyUI-Impact-Pack | Processing |

## Troubleshooting

### TritonMissing error during generation
In the `WanVideoSampler` node, set `torch_compile_args` to disabled/off. This is a known limitation of ComfyUI Portable's embedded Python on Windows — Triton is unavailable. Generation speed is unaffected for most GPUs.

### Out of memory on 24 GB VRAM
Enable maximum CPU offload in the ComfyUI-WanVideoWrapper settings. Module 10 was developed on A100-class hardware; full-resolution generation on 24 GB requires CPU offloading. RTX PRO 6000 (96 GB) is the recommended GPU for comfortable full-resolution generation.

### Depth extraction looks wrong
Ensure your render exports a proper depth pass (linear depth, not gamma-corrected). Canny/edge pass should use the silhouette render, not the final composite.

### Generation is very slow
At 24 GB with max CPU offload, expect 10–25 minutes for a short sequence. Use fewer frames or reduce resolution to speed up iteration.
