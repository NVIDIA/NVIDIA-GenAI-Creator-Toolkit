![](images/preview.png)

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

---

## Tips for Best Results

- **Fill the frame with your target material.** The VLM segments the dominant surface in the image. If your photo of a brick wall has a door, a window, or a person taking up significant space, the segmentation mask may be partial or incorrect. Crop tightly to just the material before loading it.

- **Shoot (or find) source photos with diffuse, flat lighting.** Raking sunlight, deep shadows, or a single strong light source bakes directional illumination into the texture — which then fights against your 3D scene's own lighting. Overcast natural light or a light box setup produces the cleanest extractions.

- **Describe the material explicitly in the prompt field.** Qwen is good at identifying obvious materials, but ambiguous surfaces (aged concrete that could read as stone, worn leather that could read as fabric) benefit from a short prompt like `weathered concrete, coarse aggregate, no moss`. This steers both the VLM identification pass and the diffusion output.

- **Use this workflow on photographs rather than renders — unless the render is purpose-built.** Renders with baked AO, stylized shading, or specular highlights contain non-physical surface data that the LoRA wasn't trained to decompose. Clean, photoreal reference images extract significantly better. If you must use a render, make it a flat-lit, shadeless material preview.

- **Expect some creative interpretation, especially on complex patterns.** Highly irregular materials (random rock fields, tangled roots, dense fabric weaves) will be interpreted and re-synthesized, not copied. The output is a plausible version of the material, not a photogrammetric capture. Use the output as a starting point and re-run with a fixed seed to explore variations.

- **Square input images produce better tiling output.** The diffusion pipeline assumes a roughly square crop for the seamless synthesis step. Strongly portrait or landscape crops can produce stretching artifacts at the tile seams. Crop your source to 1:1 before loading when possible.

- **Chain directly into Bonus B for a full PBR set.** The 4K output from this workflow is designed as the ideal input for Bonus B. Running a raw photo into Bonus B typically produces less accurate results because the lighting and perspective haven't been decomposed yet. The Bonus A → Bonus B pipeline is the intended authoring path.

- **Re-run with a new seed if seams are visible.** The texture LoRA is stochastic — some seeds produce cleaner seams than others on the same input. Before reaching for external seam-fixing tools, try 3–5 seeds on the same source image. There's usually one that tiles cleanly.
