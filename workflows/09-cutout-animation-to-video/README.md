![](images/preview.png)

# Module 09 — Cutout Animation to Video (Wan TTM)

Trajectory-controlled video generation — define exactly when and where motion happens.

---

## What It Does

Without motion guidance, video models animate unpredictably. Walls breathe, backgrounds wobble, unintended elements move. Wan TTM (Time-To-Move) Trajectory Masking gives you precise control: you specify a motion path and the frame window over which movement occurs. Everything outside the trajectory stays locked.

> **Two workflows — must be run in order.**
> Run `videoprep.json` first to prepare all inputs, then `workflow.json` for generation.
> Skipping VideoPrep or running `workflow.json` directly will fail — it depends on outputs from the first workflow.

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

## Tips for Best Results

- **VideoPrep output quality determines everything downstream.** If the SAM2 mask is leaky or the rough animation pass has major artifacts, the TTM generation will inherit those problems. Take the time to get clean VideoPrep outputs before running `workflow.json` — re-running TTM is expensive (~55 GB model, long inference).
- **Use SAM2's click-to-segment carefully on complex silhouettes.** Click inside the subject's core mass first, then add positive clicks to capture extremities (hands, hair, loose clothing edges). Add negative clicks to exclude background elements that are bleeding into the mask. A few extra clicks here saves significant cleanup later.
- **Keep your background image static and neutral.** TTM locks non-masked regions using the trajectory mask. If the background has strong patterns, gradients, or fine detail, subtle model-induced variation becomes visible as flickering. Flat or softly textured backgrounds are forgiving.
- **Match the start and last frames tightly to your intended motion arc.** The TTM model interpolates between first and last frames. If the last frame represents a position the character cannot plausibly reach given the trajectory video, the model will either warp the subject or produce an unnatural snap at the end.
- **Keep trajectory paths physically plausible.** TTM respects your trajectory mask for motion direction and magnitude, but the underlying Wan2.2 model still enforces physics-like motion priors. Extremely fast trajectories, sharp direction reversals, or implausibly large displacements produce instability — ease the motion arc.
- **Use the Preview Bridge node — do not skip it.** It exists specifically to prevent mask loss through ComfyUI's preview pipeline. Bypassing it or substituting a standard preview node will silently corrupt your painted mask before it reaches the TTM input, giving you unmasked or wrong-region motion.
- **x86_64 is not optional.** Wan2.2 uses architecture-specific CUDA kernels. Do not attempt to run this on ARM64, Apple Silicon via emulation, or RTX Spark systems — it will either fail on load or silently produce garbage output.
- **First frame and last frame must be the same resolution as the trajectory video.** A resolution mismatch between the frames and the trajectory video causes misalignment in the motion-conditioned generation step. Let VideoPrep generate all four outputs in a single run to guarantee they match.
- **For looping animation, make the last frame identical to the first.** If you need a seamless loop (e.g., idle cycle, ambient motion), set the VideoPrep source animation to loop cleanly and verify the first/last frames match before feeding TTM.

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Pre-download Wan2.2 (see above)
3. **Run VideoPrep first:** drag `videoprep.json` into ComfyUI, load your background image, queue
4. Export VideoPrep outputs (first frame, last frame, trajectory video, mask)
5. Drag `workflow.json` into ComfyUI
6. Load VideoPrep outputs
7. Queue
