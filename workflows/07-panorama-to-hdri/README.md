# Module 07 — Panorama to HDRI

> **Access requirement:** This module requires four custom EV LoRAs (EV +4, +2, -2, -4) that are currently only available through the NVIDIA DLI course [DLIT81948](https://www.nvidia.com/en-us/training/). **Without these LoRAs the workflow will not run.** Public release is pending — watch this repo for updates. If you have not taken the course, skip this module for now.

Generate a production-ready HDRI environment map from a single panoramic image.

---

## What It Does

Traditional HDRI capture requires a mirror ball, a camera capable of bracketed exposures, and a real physical environment. This workflow replaces that process: it generates five exposure stops from a single panorama using dedicated LoRAs, then merges them into a true HDRI using the Debevec algorithm.

**Pipeline**

```
Equirectangular Panorama (from Module 06 or your own)
    └── 5 Exposure LoRAs (EV+4, EV+2, base, EV-2, EV-4)
            └── 5 Diffusion Passes
                    └── LuminanceStackProcessor5Stops (Debevec merge)
                            └── 32-bit HDRI (.exr)
```

---

## Compatible Rendering Engines

| Engine | Import Path |
|--------|-------------|
| Unreal Engine | Image Based Light |
| Blender Cycles | World → Environment Texture |
| V-Ray | Dome Light |
| Arnold | Skydome Light |
| Unity HDRP | HDRI Sky Volume |

---

## Models

See [models.md](models.md) — total storage ~24.8 GB

| Model | Size | Notes |
|-------|------|-------|
| Flux Dev Kontext FP8 | 11.9 GB | Base generation model for this module |
| CLIP-L / ViT-L-14 | 250 MB | Text encoder |
| T5-XXL FP16 | 9.8 GB | Text encoder |
| Flux VAE | 340 MB | |
| Flux Turbo LoRA | 500 MB | Fast inference |
| EV +4, +2, -2, -4 LoRAs | 2 GB total | Exposure bracket generation |

> **Note:** This module uses Flux Dev Kontext — a completely different model stack from the Qwen-based modules. If you've only installed modules 01–06, you'll need to download a separate set of models for this one.

> **License:** Flux.1-dev is subject to Black Forest Labs' license terms. Review before commercial use: [flux-1-dev-non-commercial-license](https://huggingface.co/black-forest-labs/FLUX.1-dev/blob/main/LICENSE.md)

---

## Requirements

- VRAM: 16–24 GB (highest of all modules)
- Recommended input: equirectangular panorama from Module 06

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node | Purpose |
|------|---------|
| `LuminanceStackProcessor5Stops` | Merges 5 exposures into HDR using Debevec algorithm |
| `SaveImageOpenEXR` | Exports 32-bit EXR / HDRI file |
| `AutoContrastLevels` | Per-exposure histogram adjustment |

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Download Flux models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load an equirectangular panorama (2:1 ratio)
5. Queue — runs 5 passes and assembles the HDRI automatically
6. Output: `.exr` file ready to load in your renderer
