![](images/preview.png)

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

## Tips for Best Results

- **Clean, high-contrast subject-background separation gives the best layers.** Images where the subject and background share similar colors or values (e.g., a gray subject against a gray wall) will produce messier alpha edges. If you have control over the input, shoot or render with clear tonal separation between planes.
- **Resolution matters more here than in most workflows.** The layering model needs enough pixel detail to accurately classify edges. Feed it images at 1024px or higher on the short edge. Upscale a low-res input first rather than running deconstruction on a 512px thumbnail — thin edges like hair and foliage will be lost.
- **Avoid images with heavy motion blur or out-of-focus subjects.** Blur makes depth plane boundaries ambiguous, and the model will collapse blurry midground elements into the background layer. Crisp focus throughout the frame produces the cleanest layer separation.
- **Images with clear depth layering decompose better than flat compositions.** A photo with a distinct foreground subject, a readable midground, and a separated background will extract cleanly. A scene where everything is at the same focal plane (flat lay, overhead product shot) may produce a weak or empty midground layer.
- **Check the repaired background before using it downstream.** The background inpainting is context-aware but not perfect. Areas where the foreground subject is large or complex (a person filling 60% of the frame) will have more visible repair artifacts. Plan to use Module 03 (Targeted Inpainting) to clean those areas if they'll be visible in the final comp.
- **Use the alpha layers directly for compositing rather than exporting flattened PNGs.** The alpha channel output is your precision asset. Flatten only at the final stage of your pipeline to preserve compositing flexibility.
- **For the best normals and depth passes, run the image through Marigold or NVIDIA Diffusion Render separately.** The Qwen Layered model focuses on semantic separation (what is foreground vs. background), not geometric data. If you need accurate surface normals or metrically consistent depth, the decomposition layers are a starting point, not a replacement for a dedicated geometry model.
- **Images with transparent or translucent objects are a known weak point.** Glass, smoke, water surfaces, and thin fabric confuse the semantic layering logic. Expect these elements to land inconsistently between layers and plan for manual cleanup.
- **Batch consistent inputs.** If you're processing a sequence for animation or a set of assets for the same comp, keep input resolution, aspect ratio, and color grading consistent. Variation between frames causes inconsistent layer quality across the batch.

---

## Usage

1. Run `install.sh` / `install.bat` to install all node packs (or install them manually per [nodes.md](nodes.md))
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load your input image
5. Queue — outputs three separate layer images
