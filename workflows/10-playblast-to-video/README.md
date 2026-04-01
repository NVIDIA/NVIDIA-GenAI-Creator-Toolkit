# Module 10 — Playblast to Video (Wan Vid2Vid)

Transform a basic 3D render into a stylized, production-quality video — without re-animating or re-rendering.

---

## What It Does

Takes a low-fidelity 3D render (flat shading, no textures, simple lighting) that has correct motion and camera work, and converts it into a high-quality stylized video. Depth and edge passes preserve the 3D structure while a single reference image drives the visual style consistently across the full sequence.

**Pipeline**

```
3D Animation Render (beauty pass)
    ├── Depth Pass  ──────────────┐
    └── Canny/Edge Pass (or       ├── Wan2.2 Vid2Vid
        generate from beauty) ───┘        │
                                          │
Style Reference Image ────────────────────┘
                                          │
                                    Stylized Video
```

---

## Why This Works

| Control Pass | What It Locks |
|---|---|
| Depth | Spatial layout, scale, camera perspective |
| Canny/Edges | Silhouettes, character contours, object shapes |
| Style Reference | Color palette, materials, rendering language |

Swap the style reference image to explore different art directions using the same animation — no re-rendering required.

---

## Exporting Passes from Your 3D Application

| Pass | Notes |
|------|-------|
| Beauty render | Color video — the base animation |
| Depth pass | Normalized Z-depth; export as 16-bit if possible |
| Canny/Edge | Can be generated in-workflow from the beauty render if your app doesn't export edges |

Supported sources: Blender, Maya, Cinema 4D, Unreal Engine — any app that can render video passes.

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
| Wan2.2 T2V 720P | ~28 GB | `Wan-AI/Wan2.2-T2V-14B-720P` |
| UMT5-XXL | ~10 GB | Bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | Bundled with Wan2.2 |

Pre-download strongly recommended:

```bash
huggingface-cli download Wan-AI/Wan2.2-T2V-14B-720P --local-dir ComfyUI/models/video/wan
```

> If you already downloaded Wan2.2 for Module 09, the text encoder and VAE are shared.

---

## Requirements

- VRAM: 16–24 GB
- x86_64 only
- A 3D application that can export beauty + depth passes

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | Wan2.2 model loading and Vid2Vid |
| [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O and frame extraction |
| [comfyui_controlnet_aux](https://github.com/Fannovel16/comfyui_controlnet_aux) | Canny edge extraction from beauty render |

---

## Usage

1. Export beauty render, depth pass, and (optionally) edge pass from your 3D app
2. Choose a style reference image
3. Install custom nodes via ComfyUI Manager
4. Pre-download Wan2.2 (see above)
5. Drag `workflow.json` into ComfyUI
6. Load your render passes and style image
7. Queue
