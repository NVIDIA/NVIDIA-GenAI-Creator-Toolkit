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

See [models.md](models.md) — total storage ~8–12 GB

| Model | Source | Output |
|-------|--------|--------|
| Lotus Depth | `prs-eth/lotus-depth-g-v1-1` | Depth map |
| Lotus Normal | `prs-eth/lotus-normal-g-v1-1` | Normal map |
| Marigold Appearance | `prs-eth/marigold-appearance` | Roughness, Metallic, Albedo |
| Marigold Light | `prs-eth/marigold-lcm-v1-0` | Lighting separation |

---

## Requirements

- VRAM: 8 GB minimum
- Best results when input comes from Bonus A (seamless, uniform texture)

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Purpose |
|-----------|---------|
| [ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold) | Marigold appearance decomposition |
| Marigold HDR wrapper extensions | Marigold Light pass (shared with Module 07) |
| Padding/cropping + level nodes | Gradient shift correction |

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Download Lotus and Marigold models (they download automatically on first run)
3. Drag `workflow.json` into ComfyUI
4. Load a flat, seamless texture (Bonus A output recommended)
5. Queue — outputs all PBR maps as separate images
