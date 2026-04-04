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

---

## Tips for Best Results

- **Start with a Bonus A output, not a raw photo.** Marigold's appearance decomposition works on the assumption that lighting has been removed and the texture is spatially uniform. A photo with directional shadows or perspective distortion produces albedo maps with baked lighting and roughness maps that vary across the surface in ways that don't reflect the actual material. Bonus A removes these artifacts before they reach this pipeline.

- **Check the depth map first before trusting the normal map.** Lotus derives normals from the depth estimate. If the depth map has gradient shift artifacts (a brightness ramp across the image), the normal map will show the same directional drift as false surface tilt. Use the padding correction nodes to fix depth before the normals are baked, not after.

- **The Metallic map is the most fragile output — validate it in context.** Marigold's metallic prediction is strong for clearly metallic or clearly dielectric materials, but mid-range values on ambiguous surfaces (painted metal, brushed surfaces, wet stone) need a sanity check in your renderer. Connect the map and do a quick IPR render under a neutral HDRI before committing to it.

- **For displacement, use the Height map with conservative values first.** Lotus depth output has plausible relative surface variation but it's not a calibrated measurement. Start with low tessellation and small displacement amounts (0.01–0.05 cm range in Blender, sub-centimeter in Unreal), then dial up. Aggressive displacement on a map that wasn't geometrically surveyed will produce broken silhouettes on hard edges.

- **For tileable materials, verify all maps tile in sync.** Each map (albedo, normal, roughness, metallic, height) is generated independently. On a large, complex tile, slight alignment drift between maps is possible. Do a UV tiling preview in your renderer with all maps loaded simultaneously before treating the set as final.

- **Roughness and Albedo are your most reliable maps — use them to anchor the material.** Marigold's appearance model has the most training signal for surface color and microsurface scatter. If the metallic or height maps look wrong, dial those back and lean on the roughness/albedo pair. A well-tuned roughness map will do more work in most renderers than a noisy height map.

- **Run the full pipeline at the target output resolution.** Both Lotus and Marigold are sensitive to input resolution — downsampling the texture before this workflow produces coarser maps with less surface detail. Feed the full 4K output from Bonus A directly, and output at the same resolution. Downsampling for your final asset is a separate step after the maps are generated.

- **For organic or irregular materials, increase the padding in the gradient correction nodes.** The automatic gradient correction works well for most materials, but highly irregular surfaces (rough stone, bark, gravel) can have genuine large-scale tonal variation that the correction misidentifies as gradient shift. Adjust padding size incrementally rather than maxing it out, and compare against the uncorrected depth as a reference.
