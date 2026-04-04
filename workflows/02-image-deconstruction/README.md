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
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB |
| Qwen Image Layered VAE | 170 MB |
| Qwen Edit Lightning 4-step BF16 LoRA | 500 MB |

---

## Requirements

- VRAM: 10–14 GB

---

## Custom Nodes

See [nodes.md](nodes.md)

This module requires three node packs — install all of them:

| Node Pack | Repo |
|-----------|------|
| [ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) | Must use `Sandbox` branch |
| [ComfyUI-WJNodes](https://github.com/807502278/ComfyUI-WJNodes) | |
| [ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | |

> The install scripts handle the `Sandbox` branch automatically. If installing manually via ComfyUI Manager, TextureAlchemy will install the wrong branch — use `git clone --branch Sandbox` instead.

---

## Usage

1. Run `install.sh` / `install.bat` to install all node packs (or install them manually per [nodes.md](nodes.md))
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load your input image
5. Queue — outputs three separate layer images
