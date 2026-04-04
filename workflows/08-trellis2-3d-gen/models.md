# Models — Module 08: Trellis2 3D Asset Gen

Total storage: 15–20 GB
VRAM: 16–24 GB

| Model | Size | Destination | Source |
|-------|------|-------------|--------|
| Trellis2 (1536 cascade) | 15–20 GB | `ComfyUI/models/trellis2` (set via `--local-dir` in download command) | `JeffreyXiang/TRELLIS-image-large` |

Trellis2 includes multiple components:
- Structured latent diffusion models
- Texture generation models
- Shape conditioning models

All components download together via the ComfyUI-TRELLIS2 node's model loader. Pre-download recommended given the size:

```bash
huggingface-cli download JeffreyXiang/TRELLIS-image-large --local-dir ComfyUI/models/trellis2
```
