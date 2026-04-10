# Models — Module 06: Equirectangular Outpainting

Total storage: ~29.7 GB
VRAM: 12–16 GB

| Model | Size | Destination | Source |
|-------|------|-------------|--------|
| Qwen Image Edit 2511 BF16 | 13.5 GB | `ComfyUI/models/diffusion_models/qwen/` | `Qwen/Qwen-Image-Edit-2511` |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB | `ComfyUI/models/text_encoders/qwen/` | `Qwen/Qwen2.5-VL-7B` |
| Qwen Image VAE | 170 MB | `ComfyUI/models/vae/qwen/` | bundled |
| Qwen Lightning 8-step LoRA | 500 MB | `ComfyUI/models/loras/qwen/` | bundled |
| MikMumpitz 360 LoRA | 282 MB | `ComfyUI/models/loras/qwen/` | `TheMindExpansionNetwork/special-loras` — conditions output for correct equirectangular spherical perspective |
| Object Remover LoRA | 230 MB | `ComfyUI/models/loras/qwen/` | `prithivMLmods/Qwen-Image-Edit-2511-Object-Remover` — reused from Module 03 for seam removal |

> The MikMumpitz 360 LoRA is the key ingredient here — without it, outpainting doesn't produce a correct equirectangular projection.
