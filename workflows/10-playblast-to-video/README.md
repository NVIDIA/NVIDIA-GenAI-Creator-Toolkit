![](images/preview.png)

# Module 10 — Playblast to Video (Wan VACE)

Transform a basic 3D render into a stylized, production-quality video — without re-animating or re-rendering.

---

## What It Does

Takes a low-fidelity 3D render (flat shading, no textures, simple lighting) that has correct motion and camera work, and converts it into a high-quality stylized video. Lotus extracts depth from the input video automatically — no separate depth pass export required from your 3D application. A single reference image drives the visual style consistently across the full sequence.

**Pipeline**

```
3D Animation Render (beauty pass)
    └── Lotus Depth Estimation (auto, in-workflow)
            └── Wan2.2 Fun VACE (video-conditioned generation)
                        │
Style Reference Image ──┘
                        │
                  Stylized Video
```

---

## What You Control

| Input | What It Locks |
|---|---|
| Beauty render | Motion, timing, camera movement |
| Lotus depth (auto) | Spatial layout, scale, camera perspective |
| Style reference image | Color palette, materials, rendering language |

Swap the style reference image to explore different art directions using the same animation — no re-rendering required.

---

## Exporting From Your 3D Application

Only the beauty render is required. Depth is generated automatically from the beauty video using Lotus inside the workflow.

| Pass | Notes |
|------|-------|
| Beauty render | Color video — the base animation |

Supported sources: Blender, Maya, Cinema 4D, Unreal Engine — any app that can render video.

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
| Wan2.2 Fun VACE | ~28 GB | `Wan-AI/Wan2.2-Fun-14B-VACE` |
| UMT5-XXL | ~10 GB | Bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | Bundled with Wan2.2 |
| Lotus Depth | ~2 GB | `Kijai/lotus-comfyui` |
| Lotus VAE | ~300 MB | `jingheya/lotus-depth-g-v2-0-disparity` |

Pre-download strongly recommended:

```bash
huggingface-cli download Wan-AI/Wan2.2-Fun-14B-VACE --local-dir ComfyUI/models/video/wan
```

> If you already downloaded Wan2.2 for Module 09, the text encoder and VAE are shared.

---

## Requirements

- VRAM: 16–24 GB
- x86_64 only
- A 3D application that can render a beauty video pass

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | Wan2.2 VACE model loading and video generation |
| [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O and frame extraction |
| [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| [ComfyUI-Lotus](https://github.com/kijai/ComfyUI-Lotus) | Depth estimation from video frames |
| [radiance](https://github.com/fxtdstudios/radiance) | AI upscale and film look post-processing |
| [cg-use-everywhere](https://github.com/chrisgoringe/cg-use-everywhere) | Seed routing |
| [ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts) | String utilities |

---

## Usage

1. Export your 3D animation as a beauty render video
2. Choose a style reference image
3. Install custom nodes via ComfyUI Manager
4. Pre-download Wan2.2 (see above)
5. Drag `workflow.json` into ComfyUI
6. Load your render and style image
7. Queue
