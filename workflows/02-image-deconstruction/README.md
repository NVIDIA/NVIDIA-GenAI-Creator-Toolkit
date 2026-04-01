# Module 02 — Image Deconstruction

Split any image into foreground, midground, and background layers — with alpha channels and automatic background repair.

---

## What It Does

Extracting individual elements from an image manually is slow and inconsistent. This workflow uses Qwen Image Layered to decompose an image into clean, editable layers automatically — including filling in the gaps left behind when objects are removed.

**Pipeline**

```
Input Image
    └── Qwen Image Layered
            ├── Foreground layer (with alpha)
            ├── Midground layer (with alpha)
            └── Background layer (repaired)
```

---

## Use Cases

- Compositing and asset reuse across scenes
- Separating subjects from backgrounds for further processing
- Feeding layers into Module 03 (Inpainting) or Module 04 (Gaussian Splat)
- Automating what would otherwise take hours of manual masking

---

## Going Further

Other decomposition models can extract different data from the same input:

| Model | Output |
|-------|--------|
| NVIDIA Diffusion Render | G-Buffers (depth, normals, albedo) |
| Marigold | Depth, surface normals |
| RGBX | Intrinsic appearance maps |

---

## Models

See [models.md](models.md) — total storage ~21.5 GB

| Model | Size |
|-------|------|
| Qwen Image Layered BF16 | 13.5 GB |
| Qwen 2.5 VL 7B Text Encoder FP8 | 7.3 GB |
| Qwen Image Layered VAE | 170 MB |
| Qwen Edit Lightning 4-step LoRA | 500 MB |

---

## Requirements

- VRAM: 10–14 GB

---

## Custom Nodes

See [nodes.md](nodes.md)

The required nodes (`ReferenceLatent`, `EmptyQwenImageLayeredLatentImage`, `LatentCutToBatch`) install automatically alongside the Qwen Image Layered model via ComfyUI Manager — no additional node packs needed.

---

## Usage

1. Install the Qwen Image Layered model via ComfyUI Manager (companion nodes install with it)
2. Drag `workflow.json` into ComfyUI
3. Load your input image
4. Queue — outputs three separate layer images
