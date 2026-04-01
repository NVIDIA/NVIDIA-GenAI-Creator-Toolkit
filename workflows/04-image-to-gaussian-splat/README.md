# Module 04 — Image to Gaussian Splat

Convert a single 2D image into a navigable 3D Gaussian point cloud.

---

## What It Does

A photograph captures one angle. Gaussian splatting reconstructs the depth and 3D structure of the scene, letting you explore new viewpoints from what was originally a flat reference image.

This workflow uses SHARP, a model that infers depth at high spatial resolution from a single image, producing dense and accurate Gaussian Splats. If your image has EXIF focal length data (photos from a phone or DSLR), the workflow reads it automatically to improve reconstruction accuracy.

**Pipeline**

```
Input Image (+ EXIF focal length if available)
    └── SHARP depth inference
            └── 3D Gaussian Point Cloud (.ply)
```

---

## Output

The workflow produces a `.ply` Gaussian Splat file viewable in:

- [Supersplat](https://supersplat.dev) — browser-based viewer
- Blender (via Gaussian Splatting add-on)
- Luma AI viewer
- Any 3DGS-compatible application

---

## Pairs Well With

- **Module 05** — Fill occluded areas in the Gaussian Splat for full camera freedom
- **Module 08** — Generate a textured 3D mesh from the same reference image

---

## Models

See [models.md](models.md) — total storage ~3–5 GB

| Model | Notes |
|-------|-------|
| SHARP | Bundled with ComfyUI-Sharp — no separate download |

---

## Requirements

- VRAM: 8 GB minimum

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Key Nodes |
|-----------|-----------|
| [ComfyUI-Sharp](https://github.com/PozzettiAndrea/ComfyUI-Sharp) | `LoadImageWithExif`, `SharpPredict` |
| [ComfyUI-GeometryPack](https://github.com/PozzettiAndrea/ComfyUI-GeometryPack) | `GeomPackPreviewGaussian` |

---

## Usage

1. Install both custom node packs via ComfyUI Manager
2. Drag `workflow.json` into ComfyUI
3. Load your input image (photos with EXIF data produce better results)
4. Queue — outputs a `.ply` Gaussian Splat file
