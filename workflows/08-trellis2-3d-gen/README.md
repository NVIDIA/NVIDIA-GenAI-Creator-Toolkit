![](images/preview.png)

# Module 08 — Trellis2 3D Asset Gen

Convert a 2D image reference into a textured 3D model with PBR materials.

---

## What It Does

Trellis2 takes a single image and produces a fully textured 3D mesh in GLB format. The output includes PBR materials — albedo, roughness, metallic — making it immediately compatible with modern rendering engines without additional material work.

**Pipeline**

```
Input Image
    └── Trellis2 (shape generation)
            └── Trellis2 (PBR texture generation)
                    └── Textured 3D Model (.glb)
```

---

## Output Formats

| Format | Notes |
|--------|-------|
| `.glb` | GLTF Binary — universal, textures embedded |
| `.obj` + maps | For applications that prefer separate texture files |

---

## Use Cases

- Previs and layout blocking from photo references
- Generating stand-in geometry for complex shots
- Starting meshes for further refinement in Blender, Maya, or Unreal
- Pairing with Module 04 for richer asset reconstruction

---

## Models

See [models.md](models.md) — total storage ~15–20 GB

| Model | Size | Source |
|-------|------|--------|
| Trellis2 (1536 cascade) | 15–20 GB | `JeffreyXiang/TRELLIS-image-large` |

Pre-download recommended:

```bash
huggingface-cli download JeffreyXiang/TRELLIS-image-large --local-dir ComfyUI/models/trellis2
```

---

## Requirements

- VRAM: 16–24 GB
- Clean subject on neutral background produces the best mesh quality

---

## Custom Nodes

See [nodes.md](nodes.md)

| Node Pack | Key Nodes |
|-----------|-----------|
| [ComfyUI-TRELLIS2](https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2) | `LoadTrellis2Models`, `Trellis2GetConditioning`, `Trellis2ImageToShape`, `Trellis2ShapeToTexturedMesh`, `Trellis2ExportGLB`, `Preview3D` |

After installing via ComfyUI Manager, install Python dependencies:

```bash
cd ComfyUI/custom_nodes/ComfyUI-TRELLIS2
pip install -r requirements.txt
```

---

## Tips for Best Results

- **Subject isolation is the single biggest quality lever.** Trellis2 infers 3D geometry from a 2D silhouette. A busy or cluttered background confuses the shape stage and produces fused or incomplete geometry. Use a plain white, gray, or transparent-background image whenever possible. If your source is a photo, mask the subject first — even a rough mask is far better than none.
- **Shoot or render the subject from a 3/4 angle, not dead-on.** A front-facing flat view gives the model almost no depth cues. A 3/4 or slight above-center angle provides enough perspective to infer convincing geometry on the unseen back faces.
- **Keep input resolution moderate — 512–1024px on the long edge is the sweet spot.** Very high-res inputs slow texture generation without proportionally improving UV quality. Downscale your reference before loading if it's above 2K.
- **Simple, hard-surfaced objects reconstruct better than organic or complex subjects.** Props, vehicles, furniture, and architecture produce clean meshes. Fur, hair, foliage, and highly translucent materials (glass, fabric) are hard for single-view reconstruction — expect to fix these in your DCC tool.
- **Inspect the `.glb` in a mesh viewer before committing to a pipeline.** Open it in Blender or an online GLTF viewer immediately after generation. Topology errors (holes, non-manifold edges, flipped normals) are much faster to fix now than after you've already taken the asset downstream.
- **The back of the model is always an inference.** Trellis2 is generating a plausible back from a single view — it cannot know what's there. For assets where the back is visible (hero props, characters), plan for a cleanup pass in Blender or ZBrush.
- **Pair with Module 04 for richer results.** If you can generate multiple views of your subject (front, side, back) using another module before feeding Trellis2, even just as separate crops of a multiview sheet, the geometry quality improves substantially.
- **PBR maps are baked from the diffusion pass, not physically measured.** Roughness and metallic values are plausible but may not match real-world material properties. Treat them as a starting point and adjust in your material editor for final renders.

---

## Usage

1. Install ComfyUI-TRELLIS2 via ComfyUI Manager and run `pip install -r requirements.txt`
2. Pre-download the Trellis2 model (see above)
3. Drag `workflow.json` into ComfyUI
4. Load a clean reference image
5. Queue — outputs a `.glb` file with embedded PBR textures
