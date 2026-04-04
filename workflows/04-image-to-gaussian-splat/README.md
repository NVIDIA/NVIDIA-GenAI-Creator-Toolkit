![](images/preview.png)

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

## Tips for Best Results

- **Start with a photo, not a render.** Real photographs carry natural depth cues — parallax, defocus blur, surface texture — that SHARP uses to infer geometry. Flat renders or illustrations often produce shallow, unconvincing splats.
- **Shoot slightly elevated and wide.** A camera angle 5–15° above eye level gives SHARP a better view of ground planes and object tops, which fills in the splat geometry more completely. Very flat or very steep angles both create large dead zones.
- **Keep EXIF data intact.** If your camera's focal length is embedded in the image metadata, the workflow reads it automatically to calibrate perspective. Stripping metadata (e.g., via certain export or screenshot workflows) removes this advantage and can skew the depth field.
- **Avoid heavy foreground occlusion.** Objects right at the edge of frame, or large elements that block most of the mid and background, leave holes the model can't fill from a single view. Composition that shows clear depth layers — foreground, midground, background — reconstructs best.
- **Higher source resolution is worth it.** SHARP operates on spatial detail to infer depth boundaries. A crisp 4K photo will produce sharper point cloud edges than an upscaled 1080p crop. Try to use the full-resolution original rather than a web-compressed version.
- **Scenes with varied depth reconstruct better than flat ones.** A forest path, a cluttered workshop, or a street receding into the distance all give the model strong depth gradients to work with. A white wall or a flat product shot on a table gives it almost nothing.
- **Inspect in Supersplat before moving to Module 05.** Supersplat's browser viewer lets you orbit the scene quickly and spot which areas have gaps, thin geometry, or floaters. Identifying the problem areas first tells you what to expect from SceneFill and whether a better source image would help more.
- **If the splat looks flat, try a lens with more natural perspective.** Telephoto-compressed shots (long zoom lenses) collapse depth. A standard or slightly wide focal length (24–50mm equivalent) preserves the parallax gradients SHARP needs.
- **Floaters around fine detail are normal — work with them.** Hair, foliage, chain-link, and glass all produce noisy splat regions. If these are compositionally important, plan to use Module 05 to reconstruct around them rather than expecting clean geometry from a single image.

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
