# Models — Module 09: Cutout Animation to Video (Wan TTM)

Pre-download strongly recommended — Wan2.2 is large.

VRAM: 16–24 GB recommended

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 I2V 480P | ~28 GB | `Wan-AI/Wan2.2-I2V-14B-480P` |
| UMT5-XXL (text encoder) | ~10 GB | bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | bundled with Wan2.2 |

```bash
huggingface-cli download Wan-AI/Wan2.2-I2V-14B-480P --local-dir ComfyUI/models/video/wan
```

**Platform:** Windows x86_64 and Linux x86_64 only. Not supported on ARM64 / RTX Spark.
