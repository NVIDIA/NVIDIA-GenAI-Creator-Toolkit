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

## Usage

1. Install ComfyUI-TRELLIS2 via ComfyUI Manager and run `pip install -r requirements.txt`
2. Pre-download the Trellis2 model (see above)
3. Drag `workflow.json` into ComfyUI
4. Load a clean reference image
5. Queue — outputs a `.glb` file with embedded PBR textures
