# Models — Module 06: Equirectangular Outpainting

Total storage: ~29.7 GB
VRAM: 12–16 GB

| Model | Size | Source |
|-------|------|--------|
| Qwen Image Edit 2511 BF16 | 13.5 GB | `Qwen/Qwen-Image-Edit-2511` |
| Qwen 2.5 VL 7B Text Encoder | 14.5 GB | `Qwen/Qwen2.5-VL-7B` |
| Qwen Image VAE | 170 MB | bundled |
| Qwen Lightning 8-step LoRA | 500 MB | bundled |
| MikMumpitz 360 LoRA | 500 MB | DLI course asset — conditions output for correct equirectangular spherical perspective |
| Object Remover LoRA | 500 MB | `lightx2v/Qwen-Image-Edit-Object-Remover` — reused from Module 03 for seam removal |

> The MikMumpitz 360 LoRA is the key ingredient here — without it, outpainting doesn't produce a correct equirectangular projection.
