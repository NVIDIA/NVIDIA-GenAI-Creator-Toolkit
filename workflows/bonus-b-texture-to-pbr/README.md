![](images/preview.png)

# Bonus B — Texture to PBR

Generate a complete PBR material set from a single texture image.

---

## What It Does

Uses Lotus for geometric map extraction and Marigold for appearance decomposition. Together they produce the full set of maps needed for physically-based rendering — including Metallic, which tools like Adobe Substance Sampler don't output.

**Pipeline**

```
Input Texture (ideally from Bonus A)
    ├── Lotus Depth  ──────────── Depth map
    ├── Lotus Normal ──────────── Normal map
    ├── Marigold Appearance ───── Roughness, Metallic, Albedo
    └── Marigold Light ─────────── Lighting separation
```

---

## Output Maps

| Map | Model | Use |
|-----|-------|-----|
| Normal | Lotus | Surface micro-detail, bump |
| Depth / Height | Lotus | Displacement, tessellation |
| Albedo | Marigold Appearance | Base color without baked lighting |
| Roughness | Marigold Appearance | Surface microsurface scatter |
| Metallic | Marigold Appearance | Metal vs. dielectric |
| Lighting | Marigold Light | Separate baked illumination from albedo |

---

## Compatible Renderers

Unreal Engine · Blender Cycles / EEVEE · V-Ray · Arnold · Unity HDRP

---

## A Note on Gradient Shifts

Marigold depth and height outputs can develop gradient shifts — a gradual brightness ramp across the map that doesn't represent actual geometry. The workflow includes padding, cropping, and level adjustment steps to correct this automatically. For severe cases, adjust the padding size in the correction nodes.

---

## Models

See [models.md](models.md) — total storage ~37 GB

> **Note on storage:** The ~37 GB figure includes the full Qwen Image Edit 2511 stack (~28 GB), which is shared with Modules 03, 05, 06, and Bonus A. If you've run any of those, you only need to download the Lotus models and the upscaler (~6 GB additional). Marigold models auto-download on first run.

| Model | Source | Output |
|-------|--------|--------|
| Lotus Depth | `Kijai/lotus-comfyui` | Depth map |
| Lotus Normal | `Kijai/lotus-comfyui` | Normal map |
| Marigold Appearance | auto-download | Roughness, Metallic, Albedo |
| Marigold Light | auto-download | Lighting separation |

---

## Requirements

- VRAM: 8 GB minimum
- Best results when input comes from Bonus A (seamless, uniform texture)

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-Lotus](https://github.com/kijai/ComfyUI-Lotus) | Depth and normal extraction |
| [ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold) | Appearance decomposition |
| [ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) | Qwen-based generation nodes (Sandbox branch) |
| [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| [ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | Helper nodes |
| [ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch) | Crop/stitch |

---

## Usage

1. Install custom nodes via `install.sh` / `install.bat` or ComfyUI Manager
2. Download Lotus models (see [models.md](models.md)) — Marigold downloads automatically on first run
3. Drag `workflow.json` into ComfyUI
4. Load a flat, seamless texture (Bonus A output recommended)
5. Queue — outputs all PBR maps as separate images
