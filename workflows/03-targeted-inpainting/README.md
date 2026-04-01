# Module 03 — Targeted Inpainting

Edit only the pixels you select — mask a region, replace it, blend it back seamlessly.

---

## What It Does

Standard text-based image editing often alters the entire image even for small changes. This workflow uses a mask-and-patch approach: it crops to the masked region, enhances it at higher resolution in latent space, then stitches it back into the original image without visible boundaries.

**Pipeline**

```
Input Image + Mask
    └── Crop to masked region
            └── Model Conditioning (Qwen Image Edit 2511)
                    └── Diffusion
                            └── Stitch patch back into original
                                    └── Output Image
```

---

## Use Cases

- Object removal and background repair
- Controlled placement of new objects into a scene
- Set-building and room layout
- Multi-object composition while preserving the rest of the frame

---

## Model Compatibility

This workflow is model-agnostic. The diffusion backend can be swapped:

| Model Type | Example |
|------------|---------|
| RF Transformer | Qwen Image Edit 2511 (default) |
| Flow Matching | FLUX.1-dev |
| Diffusion | SDXL |
| MoE | Wan2.2 |

---

## Models

See [models.md](models.md) — total storage ~29 GB

| Model | Size |
|-------|------|
| Qwen Image Edit 2511 BF16 | 13.5 GB |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB |
| Qwen Image VAE | 170 MB |
| Qwen Lightning 8-step LoRA | 500 MB |
| Object Remover LoRA | 500 MB |

---

## Requirements

- VRAM: 12–16 GB

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node | Purpose |
|------|---------|
| `InpaintCropImproved` | Crops to mask region with context |
| `InpaintStitchImproved` | Composites patch back seamlessly |
| `TextEncodeQwenImageEditPlus` | Image-aware conditioning |
| `DifferentialDiffusion` | Blend boundary control |
| `ModelSamplingAuraFlow` | Advanced sampling for Qwen models |

---

## Usage

1. Install custom nodes via ComfyUI Manager (search by node name)
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load your image and draw a mask over the region to edit
5. Set your inpainting prompt
6. Queue
