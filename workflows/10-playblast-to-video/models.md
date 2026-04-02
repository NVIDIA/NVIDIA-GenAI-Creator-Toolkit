# Models — Module 10: Playblast to Video (Wan VACE)

Pre-download strongly recommended.

VRAM: 16–24 GB
Platform: Windows x86_64 and Linux x86_64 only

## Wan2.2 (video generation)

| Model | Size | Source |
|-------|------|--------|
| Wan2.2 Fun VACE | ~28 GB | `Wan-AI/Wan2.2-Fun-14B-VACE` |
| UMT5-XXL (text encoder) | ~10 GB | bundled with Wan2.2 |
| Wan2.2 VAE | ~1 GB | bundled with Wan2.2 |

```bash
huggingface-cli download Wan-AI/Wan2.2-Fun-14B-VACE --local-dir ComfyUI/models/video/wan
```

## Lotus (depth estimation)

| Model | File | Size | Source |
|-------|------|------|--------|
| Lotus Depth | `lotus-depth-g-v2-1-disparity-fp16.safetensors` | ~2 GB | [Kijai/lotus-comfyui](https://huggingface.co/Kijai/lotus-comfyui/resolve/main/lotus-depth-g-v2-1-disparity-fp16.safetensors) |
| Lotus VAE | `LotusVAE.safetensors` | ~300 MB | [jingheya/lotus-depth-g-v2-0-disparity](https://huggingface.co/jingheya/lotus-depth-g-v2-0-disparity/resolve/main/vae/diffusion_pytorch_model.safetensors) |

> Lotus runs on the input video frames to extract depth conditioning automatically — you do not need to export a depth pass from your 3D application.

> If you downloaded Wan2.2 for Module 09, the text encoder and VAE are shared. Only the diffusion model differs (VACE variant vs I2V).
