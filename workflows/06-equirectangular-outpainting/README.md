# Module 06 — Image to Seamless Equirectangular Panorama

Turn a single image into a seamless 360° equirectangular panorama ready for spherical mapping.

---

## What It Does

Creating a correct equirectangular panorama from a single image isn't just outpainting — the projection geometry has to be right or the image won't wrap seamlessly onto a sphere. This workflow combines a specialized 360° LoRA with outpainting and targeted inpainting to extend the image in all directions and then remove any visible seams.

**Pipeline**

```
Input Image
    └── Pad canvas for outpainting
            └── MikMumpitz 360 LoRA + Diffusion (outpaint)
                    └── Targeted inpainting (seam removal)
                            └── Seamless 2:1 equirectangular output
```

---

## Output

A 2:1 ratio equirectangular image (.png) ready for:

- **Module 07** — Convert to a full HDRI for 3D lighting
- Unreal Engine, Blender, Unity — as a 360° backdrop or skybox
- Spherical video backgrounds

---

## Models

See [models.md](models.md) — total storage ~29.7 GB

| Model | Size | Notes |
|-------|------|-------|
| Qwen Image Edit 2511 BF16 | 13.5 GB | Base generation model |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB | |
| Qwen Image VAE | 170 MB | |
| Qwen Lightning 8-step LoRA | 500 MB | |
| MikMumpitz 360 LoRA | 500 MB | Key ingredient — equirectangular perspective |
| Object Remover LoRA | 500 MB | Reused from Module 03 for seam removal |

> The MikMumpitz 360 LoRA is what makes the outpainting produce a correct spherical projection. Standard outpainting without it will not wrap correctly.

---

## Requirements

- VRAM: 12–16 GB

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node | Purpose |
|------|---------|
| `TextureOffset` | Horizontal image wrap for seamless tiling |
| `ImagePadForOutpaint` | Canvas expansion for outpainting |
| `InpaintCropImproved` | Targeted crop for seam inpainting |
| `CreateShapeMask` | Geometric mask generation |
| `SimpleInpaintStitch` | Seamless stitch after seam removal |

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load a landscape or interior image (wider aspect ratio works best)
5. Queue — outputs a 2:1 equirectangular image
