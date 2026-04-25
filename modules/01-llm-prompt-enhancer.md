<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Module 01 — LLM Prompt Enhancer

> Builds an AI agent that refines weak prompts into model-ready instructions using Gemma 3 via Ollama.

→ [Workflow files and usage guide](../workflows/01-llm-prompt-enhancer/)

## Models

| Model | Source | Size | Destination |
|-------|--------|------|-------------|
| `qwen_image_2512_bf16.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~41 GB | models/diffusion_models/qwen/ |
| `qwen_2.5_vl_7b.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~17 GB | models/text_encoders/qwen/ |
| `qwen_image_vae.safetensors` | Comfy-Org/Qwen-Image_ComfyUI | ~255 MB | models/vae/qwen/ |
| `Qwen-Image-2512-Lightning-4steps-V1.0-fp32.safetensors` | lightx2v/Qwen-Image-2512-Lightning | ~1 GB | models/loras/qwen/ |
| Gemma 3 (via Ollama) | `ollama pull gemma3` | ~5 GB | Managed by Ollama |

> Gemma 3 is pulled through Ollama rather than downloaded from HuggingFace. Run `ollama pull gemma3` in a terminal before using this workflow.

## Custom Nodes

| Node | URL | Notes |
|------|-----|-------|
| ComfyUI-Manager | https://github.com/ltdrdata/ComfyUI-Manager | Core, always installed |
| ComfyUI-WJNodes | https://github.com/807502278/ComfyUI-WJNodes | Qwen utilities |
| ComfyUI-Easy-Use | https://github.com/yolain/ComfyUI-Easy-Use | Qwen utilities |
| comfyui-ollama | https://github.com/stavsap/comfyui-ollama | Ollama LLM integration |

## Troubleshooting

### Ollama not detected at startup
Make sure Ollama is running as a background service (`ollama serve`). On Windows, Ollama starts automatically after install. On Linux, run `ollama serve &` before launching ComfyUI.

### gemma3 not found
Run `ollama pull gemma3` in a terminal. The model must be pulled before the workflow can use it.

### comfyui-ollama node missing
Run `install.bat / install.sh --modules 01` to install the Ollama node pack, then restart ComfyUI.
