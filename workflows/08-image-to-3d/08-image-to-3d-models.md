# Models — Module 08: Trellis2 3D Asset Gen

Total storage: ~20 GB
VRAM: 16–24 GB

| Model | Size | Destination | Source |
|-------|------|-------------|--------|
| TRELLIS.2-4B | ~16 GB | `ComfyUI/models/microsoft/TRELLIS.2-4B/` | `microsoft/TRELLIS.2-4B` |
| DINOv3 ViT-L/16 ⚠️ gated | ~1 GB | `ComfyUI/models/facebook/dinov3-vitl16-pretrain-lvd1689m/` | `facebook/dinov3-vitl16-pretrain-lvd1689m` |
| TRELLIS-image-large (shape decoder) | ~3 GB | `ComfyUI/models/microsoft/TRELLIS-image-large/` | `microsoft/TRELLIS-image-large` |

> **Note:** DINOv3 is a gated model. Accept Meta's data agreement at [huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m](https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m) and run `huggingface-cli login` before downloading.

Download all three with:

```bash
python download_models.py --comfyui C:\path\to\ComfyUI --modules 08
```

Or manually:

```bash
huggingface-cli download microsoft/TRELLIS.2-4B --local-dir ComfyUI/models/microsoft/TRELLIS.2-4B
huggingface-cli download facebook/dinov3-vitl16-pretrain-lvd1689m --local-dir ComfyUI/models/facebook/dinov3-vitl16-pretrain-lvd1689m
huggingface-cli download microsoft/TRELLIS-image-large --local-dir ComfyUI/models/microsoft/TRELLIS-image-large
```
