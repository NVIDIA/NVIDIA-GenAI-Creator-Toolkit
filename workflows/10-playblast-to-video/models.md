# Models — Module 10: Playblast to Video (Wan Vid2Vid)

Pre-download strongly recommended.

VRAM: 16–24 GB recommended

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 T2V 720P | ~28 GB | `Wan-AI/Wan2.2-T2V-14B-720P` |
| UMT5-XXL (text encoder) | ~10 GB | bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | bundled with Wan2.2 |

```bash
huggingface-cli download Wan-AI/Wan2.2-T2V-14B-720P --local-dir ComfyUI/models/video/wan
```

> If you already downloaded Wan2.2 for Module 09, the text encoder and VAE are shared — only the diffusion model variant differs between I2V and T2V.

**Platform:** Windows x86_64 and Linux x86_64 only. Not supported on ARM64 / RTX Spark.
