![](images/preview.png)

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

## Tips for Best Results

- **Mask tightly around the target, not the entire area you want changed.** The crop-and-patch approach works by resolving a small region at high resolution. An oversized mask forces the model to regenerate too much context, which increases drift from the surrounding image. Trace the actual boundary of the object you're editing, then add a small feather — don't box-select a quarter of the frame.
- **Include enough context in the mask border to guide coherent fill.** If you mask right to the pixel edge of a person, the model has no context to fill against. Expand the mask 10–20 pixels past the object's edge so the model can read the surrounding texture and lighting when it fills.
- **Write the inpainting prompt to describe what should be there, not what you removed.** "empty park bench against a stone wall" works better than "remove the person sitting on a park bench." The model fills forward from a positive description.
- **Match the lighting description in your prompt to the existing scene.** The model reads the surrounding image but responds strongly to the prompt. If the scene has warm afternoon light and your prompt says nothing about lighting, results are inconsistent. Add "warm afternoon side lighting" or similar to anchor the fill to the actual image conditions.
- **Use DifferentialDiffusion for blending, not as a creative control.** Its purpose is to smooth the seam between the patch and the original. Cranking it up doesn't produce better creative results — it produces softer, mushier edges. Keep it at a moderate value and rely on a good mask and prompt for quality.
- **For object removal, use the Object Remover LoRA.** Switch to it explicitly when your goal is clean deletion and background reconstruction. The base model is optimized for replacement; the LoRA is tuned for disappearance. Using the wrong one for removal tasks produces ghosting artifacts and incomplete fills.
- **Run multiple seeds before committing.** Inpainting has high variance even with a strong prompt. Queue 4–8 seeds at a time and pick the best result rather than iterating on a single output. The mask region is small enough that generation is fast.
- **If the seam is visible in the final output**, the mask edge is usually the cause — not the fill quality. Re-mask with a softer edge or slightly larger feather radius, then re-run. Visible seams from the stitch node almost always trace back to a hard mask boundary, not model failure.
- **For multi-object edits, do them in passes.** Edit one region, bake the result, then mask the next region. Trying to inpaint two non-adjacent objects simultaneously with one mask forces the model to fill two different regions with one conditioning pass, which produces incoherent results for at least one of them.
- **When replacing rather than removing, describe the new object's material and scale explicitly.** "a red ceramic vase, matte glaze, 30cm tall" outperforms "a vase." Material, scale, and finish details help the model produce a replacement that reads correctly against the existing scene lighting and depth.

---

## Usage

1. Install custom nodes via ComfyUI Manager (search by node name)
2. Download models listed in [models.md](models.md)
3. Drag `workflow.json` into ComfyUI
4. Load your image and draw a mask over the region to edit
5. Set your inpainting prompt
6. Queue
