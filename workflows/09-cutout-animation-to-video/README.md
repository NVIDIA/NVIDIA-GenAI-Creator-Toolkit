# Module 09 — Cutout Animation to Video (Wan TTM)

Trajectory-controlled video generation — define exactly when and where motion happens.

---

## What It Does

Without motion guidance, video models animate unpredictably. Walls breathe, backgrounds wobble, unintended elements move. Wan TTM (Time-To-Move) Trajectory Masking gives you precise control: you specify a motion path and the frame window over which movement occurs. Everything outside the trajectory stays locked.

**Pipeline**

```
First Frame + Last Frame
    └── Rough 2D Trajectory Video (draw or generate via VideoPrep)
            └── Wan TTM Trajectory Mask
                    └── Motion-Conditioned Generation
                            └── Output Video
```

> **Note:** Run the VideoPrep workflow first (see below) to generate the first frame, last frame, and trajectory video that this module requires.

---

## VideoPrep — Required Helper

The VideoPrep workflow is a prerequisite for this module. It generates:

- Matching first and last frames
- A rough animation pass for motion timing
- A clean subject mask that stays stable through generation
- Mask retention tools (prevents painted masks from being lost in preview nodes)

Run VideoPrep, export its outputs, then use them as inputs here.

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

See [models.md](models.md) — total storage ~40 GB

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 I2V 480P | ~28 GB | `Wan-AI/Wan2.2-I2V-14B-480P` |
| UMT5-XXL | ~10 GB | Bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | Bundled with Wan2.2 |

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

| Node | Purpose |
|------|---------|
| TTM Custom Node (DLI) | Trajectory mask processing |
| VideoPrep-Nodes (DLI) | First/last frame and mask preparation |
| [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O and frame extraction |

---

## Usage

1. Run the VideoPrep workflow to generate first frame, last frame, and trajectory video
2. Install custom nodes via ComfyUI Manager
3. Pre-download Wan2.2 (see above)
4. Drag `workflow.json` into ComfyUI
5. Load VideoPrep outputs
6. Queue
