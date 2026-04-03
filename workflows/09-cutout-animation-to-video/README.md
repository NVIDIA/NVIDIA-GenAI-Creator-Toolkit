# Module 09 — Cutout Animation to Video (Wan TTM)

Trajectory-controlled video generation — define exactly when and where motion happens.

---

## What It Does

Without motion guidance, video models animate unpredictably. Walls breathe, backgrounds wobble, unintended elements move. Wan TTM (Time-To-Move) Trajectory Masking gives you precise control: you specify a motion path and the frame window over which movement occurs. Everything outside the trajectory stays locked.

This module includes two workflows that must be run in sequence:

1. **`videoprep.json`** — Prepares all inputs for TTM inside ComfyUI
2. **`workflow.json`** — TTM generation using Wan2.2 I2V

---

## Step 1 — VideoPrep (`videoprep.json`)

VideoPrep generates everything TTM needs without leaving ComfyUI:

**Pipeline**

```
Background Image
    └── Subject Isolation (SAM2 click-to-segment)
            └── Rough Animation Pass (Qwen Image Edit)
                    └── Mask Extraction
                            └── Outputs: first frame, last frame,
                                        trajectory video, subject mask
```

**What it produces:**
- Matching first and last frames for continuity
- A rough animation pass for motion timing
- A clean subject mask that stays stable through generation
- A Preview Bridge that preserves painted masks (prevents loss in preview nodes)

---

## Step 2 — TTM Generation (`workflow.json`)

**Pipeline**

```
First Frame + Last Frame (from VideoPrep)
    └── Rough 2D Trajectory Video (from VideoPrep)
            └── Wan TTM Trajectory Mask
                    └── Motion-Conditioned Generation
                            └── Output Video
```

---

## What TTM Controls

| Problem | How TTM Solves It |
|---------|-------------------|
| Wrong elements animate | Trajectory mask isolates what moves |
| Motion starts/stops unpredictably | Time-gated frame windows define timing |
| Results vary run to run | Same trajectory = repeatable results |
| Background drifts | Non-masked regions stay locked |

---

## Platform Support

| Platform | Status |
|----------|--------|
| Windows x86_64 | ✅ Supported |
| Linux x86_64 | ✅ Supported |
| RTX Spark / ARM64 | ❌ Not supported — Wan2.2 requires x86_64 |

---

## Models

See [models.md](models.md) — total storage ~55 GB

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 I2V 480P | ~28 GB | `Wan-AI/Wan2.2-I2V-14B-480P` |
| UMT5-XXL | ~10 GB | Bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | Bundled with Wan2.2 |
| Qwen Image Edit 2511 BF16 | ~13.5 GB | `Comfy-Org/Qwen-Image-Edit_ComfyUI` |
| Qwen 2.5 VL 7B Text Encoder | ~14.5 GB | `Comfy-Org/Qwen-Image_ComfyUI` |
| SAM2 Hiera Tiny | ~150 MB | `Kijai/sam2-safetensors` |

Pre-download strongly recommended:

```bash
huggingface-cli download Wan-AI/Wan2.2-I2V-14B-480P --local-dir ComfyUI/models/video/wan
```

---

## Requirements

- VRAM: 16–24 GB
- x86_64 only

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [comfy_nv_video_prep](https://github.com/NVIDIA/comfy_nv_video_prep) | TTM trajectory mask processing, SAM2 segmentation, mask bridge |
| [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O and frame extraction |
| [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| [comfyui-sam2](https://github.com/neverbiasu/ComfyUI-SAM2) | Click-to-segment subject mask |
| [ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch) | Inpainting crop and stitch |
| [ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts) | String utilities |
| [ComfyUI_essentials](https://github.com/cubiq/ComfyUI_essentials) | Utility nodes |

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Pre-download Wan2.2 (see above)
3. **Run VideoPrep first:** drag `videoprep.json` into ComfyUI, load your background image, queue
4. Export VideoPrep outputs (first frame, last frame, trajectory video, mask)
5. Drag `workflow.json` into ComfyUI
6. Load VideoPrep outputs
7. Queue
