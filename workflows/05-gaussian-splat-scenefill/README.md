# Module 05 — Gaussian Splat SceneFill

Reconstruct the missing areas in a Gaussian Splat so you can freely move the camera.

---

## What It Does

When you convert a single image into a Gaussian Splat (Module 04), new camera angles reveal areas with no data — occluded surfaces, foliage edges, anything behind the subject. Standard diffusion models can't fill these areas coherently because they don't understand 3D scene structure.

This workflow uses a LoRA specifically trained for Gaussian Splat scene fill. It reconstructs the hidden areas with spatial consistency, producing a complete scene you can reframe and zoom without visible gaps.

**Pipeline**

```
Gaussian Splat output (from Module 04)
    └── Qwen Image Edit 2511 + SceneFill LoRA
            └── Diffusion
                    └── Completed scene image
```

---

## Why a LoRA?

This module demonstrates a key concept: LoRAs let you extend what a base model can do for tasks that require specialized knowledge. Filling occluded 3D areas is one of those tasks — it requires understanding depth, spatial consistency, and the 3D context behind the original image. The SceneFill LoRA is trained for exactly that.

---

## Models

See [models.md](models.md) — total storage ~29 GB

| Model | Size |
|-------|------|
| Qwen Image Edit 2511 BF16 | 13.5 GB |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB |
| Qwen Image VAE | 170 MB |
| Qwen Sharp Gaussian Splat LoRA | 500 MB |
| Qwen Lightning 8-step LoRA | 500 MB |

> If you ran Module 04, the SHARP model is already installed. This module adds only the SceneFill LoRA on top.

---

## Requirements

- VRAM: 12–16 GB
- Recommended: Run Module 04 first to generate the Gaussian Splat input

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Key Nodes |
|-----------|-----------|
| [ComfyUI-Sharp](https://github.com/PozzettiAndrea/ComfyUI-Sharp) | `LoadImageWithExif`, `SharpPredict` |
| [ComfyUI-GeometryPack](https://github.com/PozzettiAndrea/ComfyUI-GeometryPack) | `GeomPackPreviewGaussian` |

---

## Usage

1. Complete Module 04 to generate a Gaussian Splat
2. Install custom nodes via ComfyUI Manager (same as Module 04)
3. Download the SceneFill LoRA (see [models.md](models.md))
4. Drag `workflow.json` into ComfyUI
5. Queue
