# Models — Module 04: Equirectangular Outpainting

Total storage: ~29.7 GB
VRAM: 12–16 GB

| Model | Size | Destination | Source |
|-------|------|-------------|--------|
| Qwen Image Edit 2511 BF16 | ~41 GB | `ComfyUI/models/diffusion_models/qwen/` | `Qwen/Qwen-Image-Edit-2511` |
| Qwen 2.5 VL 7B Text Encoder | ~17 GB | `ComfyUI/models/text_encoders/qwen/` | `Qwen/Qwen2.5-VL-7B` |
| Qwen Image VAE | ~255 MB | `ComfyUI/models/vae/qwen/` | bundled |
| Qwen Lightning 8-step LoRA | 500 MB | `ComfyUI/models/loras/qwen/` | bundled |
| MickMumpitz 360 LoRA | 282 MB | `ComfyUI/models/loras/qwen/MickMumpitz360.safetensors` | Manual download — subscribe at [patreon.com/Mickmumpitz](https://www.patreon.com/Mickmumpitz) |
| Object Remover LoRA | 230 MB | `ComfyUI/models/loras/qwen/` | `prithivMLmods/Qwen-Image-Edit-2511-Object-Remover` — reused from Module 03 for seam removal |

> The MickMumpitz 360 LoRA is the key ingredient here — without it, outpainting doesn't produce a correct equirectangular projection.
