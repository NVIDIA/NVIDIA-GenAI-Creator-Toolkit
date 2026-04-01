# Bonus A — Texture Extraction from Image

Extract a clean, seamless, tileable texture from any image — photo, render, or AI-generated.

---

## What It Does

A VLM identifies and isolates the target material surface, a texture LoRA conditions the diffusion output for tileability, and an upscaler brings the result to 4K. The workflow handles everything from material identification to final output.

**Pipeline**

```
Input Image
    └── Qwen VLM (material identification and segmentation)
            └── Mask + Crop
                    └── Texture Extraction LoRA + Diffusion
                            └── 4K Upscale
                                    └── Seamless Tileable Texture
```

---

## Use Cases

- Recreate a material from a photo reference
- Extract surfaces from AI-generated scenes
- Generate textures for background environment assets
- Prepare material input for Bonus B (Texture → PBR)

---

## Models

See [models.md](models.md) — total storage ~29 GB

| Model | Size | Notes |
|-------|------|-------|
| Qwen Image Edit 2511 BF16 | 13.5 GB | Base generation + VLM guidance |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB | |
| Qwen Image VAE | 170 MB | |
| Extract Texture LoRA | 500 MB | Conditions output for seamless tileability |
| Qwen Lightning 8-step LoRA | 500 MB | |

> Shares the full Qwen stack with Modules 03, 05, and 06. If you've run any of those, the base models are already downloaded.

---

## Requirements

- VRAM: 12–16 GB

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node | Purpose |
|------|---------|
| `TextEncodeQwenImageEditPlus` | Image-aware conditioning |
| `ModelSamplingAuraFlow` | Advanced sampling for Qwen models |
| `DifferentialDiffusion` | Blend boundary control |
| Masking + segmentation nodes | Isolate target material |
| Upscaling nodes | 4K output |

---

## Usage

1. Install custom nodes via ComfyUI Manager
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load an image containing the target material
5. Optionally describe the material type in the prompt
6. Queue — outputs a seamless tileable texture at 4K
