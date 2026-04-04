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

---

## Tips for Best Results

- **Keep your beauty render simple — that's a feature, not a bug.** Flat shading, basic lighting, and solid colors give Lotus clean geometry to read. Overly complex renders with lens flares or post-processing glare confuse depth extraction. Save the polish for the AI output.

- **Shoot your style reference like a final frame, not a mood board.** The reference image should match the framing, scale, and lighting direction of your render as closely as possible. A hero character reference for a wide environment shot will produce inconsistent results. Crop or reframe reference images to match the render's composition.

- **Avoid motion blur in your source render.** Wan VACE is already reading motion from frame-to-frame differences. Pre-baked motion blur in the beauty pass creates ambiguous depth cues for Lotus and muddy outputs. Render with motion blur off; the model adds its own temporal smoothing.

- **Keep sequences under 120 frames when testing.** At 16–24 GB VRAM, long sequences queue large frame batches that can cause OOM crashes or very long generation times. Nail the look on a 3–4 second clip first, then run the full sequence.

- **Resolution matters for Lotus depth quality.** Input below 720p tends to produce coarse, blocky depth maps that telegraph into the final output as floating or misaligned geometry. 1080p is the sweet spot; higher than that has diminishing returns for depth accuracy.

- **Swap the style reference to art-direct without re-rendering.** The same animation can become photorealistic, cel-shaded, or painterly just by changing the reference image. Use this to pitch multiple art directions from a single blocked-out animation — it's one of the biggest workflow advantages this pipeline offers.

- **Consistent camera movement yields better temporal coherence.** Slow, deliberate camera moves (orbits, dollies, slow pans) give VACE more time per frame to maintain style consistency. Fast cuts or sudden camera snaps often produce flickering or style drift between shots. Split multi-cut sequences into individual clips.

- **If depth extraction looks wrong, check your render's exposure.** Lotus reads luminance as a proxy for depth when geometry cues are ambiguous. Overexposed or blown-out areas (pure white sky, emissive surfaces) read as near-distance geometry. Clamp your render's white point in your 3D app before exporting.

- **Use the seed control for iterative refinement.** Lock the seed after you find a result you like for a particular shot, then adjust prompts or the style reference without losing the spatial layout that worked. Randomizing seed on every run makes it hard to isolate what changed.
