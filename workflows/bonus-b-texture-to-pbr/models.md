# Models — Bonus B: Texture to PBR

Total storage: ~37 GB
VRAM: 8–12 GB

## Qwen Image Edit (base generation)

| Model | File | Size | Source |
|-------|------|------|--------|
| Qwen Image Edit 2511 BF16 | `qwen_image_edit_2511_bf16.safetensors` | 13.5 GB | [Comfy-Org/Qwen-Image-Edit_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_bf16.safetensors) |
| Qwen 2.5 VL 7B Text Encoder | `qwen_2.5_vl_7b.safetensors` | 14.5 GB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b.safetensors) |
| Qwen Image VAE | `qwen_image_vae.safetensors` | 170 MB | [Comfy-Org/Qwen-Image_ComfyUI](https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors) |
| Qwen Lightning 8-step LoRA | `Qwen-Image-Lightning-8steps-V2.0.safetensors` | 500 MB | [lightx2v/Qwen-Image-Lightning](https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V2.0.safetensors) |

## Lotus (geometric maps)

| Model | File | Size | Source | Output |
|-------|------|------|--------|--------|
| Lotus Depth | `lotus-depth-g-v2-1-disparity-fp16.safetensors` | ~2 GB | [Kijai/lotus-comfyui](https://huggingface.co/Kijai/lotus-comfyui/resolve/main/lotus-depth-g-v2-1-disparity-fp16.safetensors) | Depth / height map |
| Lotus Normal G | `lotus-normal-g-v1-0.safetensors` | ~2 GB | [Kijai/lotus-comfyui](https://huggingface.co/Kijai/lotus-comfyui/resolve/main/lotus-normal-g-v1-0.safetensors) | Normal map |
| Lotus Normal D | `lotus-normal-d-v1-0.safetensors` | ~2 GB | [Kijai/lotus-comfyui](https://huggingface.co/Kijai/lotus-comfyui/resolve/main/lotus-normal-d-v1-0.safetensors) | Normal map (deterministic) |
| Lotus VAE | `LotusVAE.safetensors` | ~300 MB | [jingheya/lotus-depth-g-v2-0-disparity](https://huggingface.co/jingheya/lotus-depth-g-v2-0-disparity/resolve/main/vae/diffusion_pytorch_model.safetensors) | Shared VAE |

## Upscaler

| Model | File | Size | Source |
|-------|------|------|--------|
| 4x-UltraSharp | `4x-UltraSharp.pth` | ~65 MB | [Kim2091/UltraSharp](https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth) |

## Marigold (appearance decomposition — auto-download)

Marigold models download automatically on first run via the ComfyUI-Marigold node. No manual download required.

| Model | Output |
|-------|--------|
| Marigold Appearance | Roughness, Metallic, Albedo |
| Marigold Light | Lighting separation |

> The Qwen base stack is shared with Modules 03, 05, 06, and Bonus A. Lotus models are shared with Module 10.
