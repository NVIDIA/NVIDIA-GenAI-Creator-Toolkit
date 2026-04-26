#!/usr/bin/env python3
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
download_models.py — ComfyUI model downloader for comfyui-generative-ai-workflows

Usage:
    python download_models.py --comfyui /path/to/ComfyUI
    python download_models.py --comfyui /path/to/ComfyUI --modules 02,03,05
    python download_models.py --comfyui /path/to/ComfyUI --modules all
"""

import argparse
import os
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

_DOWNLOAD_MAX_RETRIES = 3
_DOWNLOAD_MIN_SIZE = 1024  # files smaller than 1 KB are treated as incomplete

try:
    from huggingface_hub import hf_hub_download, snapshot_download, get_token, get_hf_file_metadata, hf_hub_url
except ImportError:
    print("[ERROR] huggingface_hub is not installed.")
    print("        Run: pip install huggingface_hub")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class ModelSpec:
    """One downloadable model."""
    name: str
    repo: str
    filename: str           # filename within the repo (may include subdirectory)
    dest_subdir: str        # relative to ComfyUI root, e.g. "models/diffusion_models/qwen"
    size: str
    # After download the file lands at dest_subdir/<basename(filename)>.
    # If rename_to is set, rename it to that name inside dest_subdir.
    rename_to: Optional[str] = None
    # If True, download the whole repo (no single filename) into dest_subdir.
    full_repo: bool = False
    # Optional git revision / commit hash to pin the download to.
    revision: Optional[str] = None
    # If set, display this agreement URL and prompt the user to confirm before downloading.
    requires_agreement: Optional[str] = None


@dataclass
class ModuleSpec:
    label: str              # e.g. "Module 01"
    name: str               # human-readable title
    models: list = field(default_factory=list)
    skip: bool = False
    skip_reason: str = ""
    manual_notes: list = field(default_factory=list)


# ---------------------------------------------------------------------------
# Shared model definitions (reused across modules)
# ---------------------------------------------------------------------------

QWEN_EDIT_DIFFUSION = ModelSpec(
    name="Qwen Image Edit 2511 BF16",
    repo="Comfy-Org/Qwen-Image-Edit_ComfyUI",
    filename="split_files/diffusion_models/qwen_image_edit_2511_bf16.safetensors",
    dest_subdir="models/diffusion_models/qwen",
    size="~41 GB",
)

QWEN_TEXT_ENCODER = ModelSpec(
    name="Qwen 2.5 VL 7B Text Encoder",
    repo="Comfy-Org/Qwen-Image_ComfyUI",
    filename="split_files/text_encoders/qwen_2.5_vl_7b.safetensors",
    dest_subdir="models/text_encoders/qwen",
    size="~17 GB",
)

QWEN_VAE = ModelSpec(
    name="Qwen Image VAE",
    repo="Comfy-Org/Qwen-Image_ComfyUI",
    filename="split_files/vae/qwen_image_vae.safetensors",
    dest_subdir="models/vae/qwen",
    size="~255 MB",
)

QWEN_TEXT_ENCODER_FP8 = ModelSpec(
    name="Qwen 2.5 VL 7B Text Encoder (FP8)",
    repo="Comfy-Org/Qwen-Image_ComfyUI",
    filename="split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors",
    dest_subdir="models/text_encoders/qwen",
    size="~9 GB",
)

QWEN_LIGHTNING_8STEP = ModelSpec(
    name="Qwen Lightning 8-step LoRA",
    repo="lightx2v/Qwen-Image-Lightning",
    filename="Qwen-Image-Lightning-8steps-V2.0.safetensors",
    dest_subdir="models/loras/qwen",
    size="~1.7 GB",
)

QWEN_LIGHTNING_EDIT_8STEP_V1 = ModelSpec(
    name="Qwen Image Edit Lightning 8-step LoRA V1.0",
    repo="lightx2v/Qwen-Image-Lightning",
    filename="Qwen-Image-Edit-Lightning-8steps-V1.0.safetensors",
    dest_subdir="models/loras/qwen",
    size="~1.7 GB",
)

# Lotus Depth G — used by bonus-b
LOTUS_DEPTH_G = ModelSpec(
    name="Lotus Depth G",
    repo="Kijai/lotus-comfyui",
    filename="lotus-depth-g-v2-1-disparity-fp16.safetensors",
    dest_subdir="models/diffusion_models/lotus",
    size="~2 GB",
)

LOTUS_VAE = ModelSpec(
    name="Lotus VAE",
    repo="jingheya/lotus-depth-g-v2-0-disparity",
    filename="vae/diffusion_pytorch_model.safetensors",
    dest_subdir="models/vae",
    size="~300 MB",
    rename_to="LotusVAE.safetensors",
)

WAN_VAE = ModelSpec(
    name="Wan 2.1 VAE",
    repo="Comfy-Org/Wan_2.1_ComfyUI_repackaged",
    filename="split_files/vae/wan_2.1_vae.safetensors",
    dest_subdir="models/vae",
    size="~250 MB",
)

WAN_TEXT_ENCODER = ModelSpec(
    name="UMT5 XXL FP16 Text Encoder",
    repo="Comfy-Org/Wan_2.1_ComfyUI_repackaged",
    filename="split_files/text_encoders/umt5_xxl_fp16.safetensors",
    dest_subdir="models/text_encoders",
    size="~11 GB",
)


# ---------------------------------------------------------------------------
# Module catalogue
# ---------------------------------------------------------------------------

def build_module_catalogue() -> dict:
    """
    Returns a dict keyed by zero-padded module number string (e.g. "01", "02",
    "bonus-a", "bonus-b").  Values are ModuleSpec instances.
    """
    catalogue = {}

    # ── Module 01 — LLM Prompt Enhancer ────────────────────────────────────
    catalogue["01"] = ModuleSpec(
        label="Module 01",
        name="LLM Prompt Enhancer",
        manual_notes=[
            "Also requires Ollama + Gemma3 LLM (not a HuggingFace download).",
            "Install Ollama: https://ollama.com/download",
            "Then run: ollama pull gemma3",
        ],
        models=[
            ModelSpec(
                name="Qwen Image 2512 BF16",
                repo="Comfy-Org/Qwen-Image_ComfyUI",
                filename="split_files/diffusion_models/qwen_image_2512_bf16.safetensors",
                dest_subdir="models/diffusion_models/qwen",
                size="~41 GB",
            ),
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            ModelSpec(
                name="Qwen Lightning 4-step FP32 LoRA",
                repo="lightx2v/Qwen-Image-2512-Lightning",
                filename="Qwen-Image-2512-Lightning-4steps-V1.0-fp32.safetensors",
                dest_subdir="models/loras/qwen",
                size="1 GB",
            ),
        ],
    )

    # ── Module 02 — Image Deconstruction ────────────────────────────────────
    catalogue["02"] = ModuleSpec(
        label="Module 02",
        name="Image Deconstruction",
        models=[
            ModelSpec(
                name="Qwen Image Layered BF16",
                repo="Comfy-Org/Qwen-Image-Layered_ComfyUI",
                filename="split_files/diffusion_models/qwen_image_layered_bf16.safetensors",
                dest_subdir="models/diffusion_models/qwen",
                size="~41 GB",
            ),
            ModelSpec(
                name="Qwen 2.5 VL 7B Text Encoder",
                repo="Comfy-Org/HunyuanVideo_1.5_repackaged",
                filename="split_files/text_encoders/qwen_2.5_vl_7b.safetensors",
                dest_subdir="models/text_encoders/qwen",
                size="~17 GB",
            ),
            ModelSpec(
                name="Qwen 2.5 VL 7B FP8 Text Encoder",
                repo="Comfy-Org/HunyuanVideo_1.5_repackaged",
                filename="split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors",
                dest_subdir="models/text_encoders/qwen",
                size="~9 GB",
            ),
            ModelSpec(
                name="Qwen Image Layered VAE",
                repo="Comfy-Org/Qwen-Image-Layered_ComfyUI",
                filename="split_files/vae/qwen_image_layered_vae.safetensors",
                dest_subdir="models/vae/qwen",
                size="~255 MB",
            ),
            ModelSpec(
                name="Qwen Edit Lightning 4-step BF16 LoRA",
                repo="lightx2v/Qwen-Image-Edit-2511-Lightning",
                filename="Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors",
                dest_subdir="models/loras/qwen",
                size="~810 MB",
            ),
        ],
    )

    # ── Module 03 — Targeted Inpainting ─────────────────────────────────────
    catalogue["03"] = ModuleSpec(
        label="Module 03",
        name="Targeted Inpainting",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER_FP8,
            QWEN_VAE,
            QWEN_LIGHTNING_EDIT_8STEP_V1,
        ],
    )

    # ── Module 04 — Image to Gaussian Splat ─────────────────────────────────
    catalogue["04"] = ModuleSpec(
        label="Module 04",
        name="Image to Gaussian Splat",
        models=[],
    )

    # ── Module 05 — Novel View Synthesis ────────────────────────────────────
    catalogue["05"] = ModuleSpec(
        label="Module 05",
        name="Novel View Synthesis",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            ModelSpec(
                name="Qwen Sharp Gaussian Splat LoRA",
                repo="dx8152/Qwen-Image-Edit-2511-Gaussian-Splash",
                filename="高斯泼溅-Sharp.safetensors",
                dest_subdir="models/loras",
                size="~230 MB",
                rename_to="Qwen2511SharpGaussianSplat.safetensors",
            ),
        ],
    )

    # ── Module 06 — Image to Equirectangular ─────────────────────────────────
    catalogue["06"] = ModuleSpec(
        label="Module 06",
        name="Image to Equirectangular",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            ModelSpec(
                name="Object Remover LoRA",
                repo="prithivMLmods/Qwen-Image-Edit-2511-Object-Remover",
                filename="Qwen-Image-Edit-2511-Object-Remover.safetensors",
                dest_subdir="models/loras/qwen",
                size="~230 MB",
            ),
            ModelSpec(
                name="MikMumpitz 360 LoRA",
                repo="TheMindExpansionNetwork/special-loras",
                filename="251018_MICKMUMPITZ_QWEN-EDIT_360_03.safetensors",
                dest_subdir="models/loras/qwen",
                size="~280 MB",
                rename_to="MikMumpitz360.safetensors",
            ),
        ],
    )

    # ── Module 07 — Panorama to HDRI ────────────────────────────────────────
    catalogue["07"] = ModuleSpec(
        label="Module 07",
        name="Panorama to HDRI",
        models=[
            ModelSpec(
                name="Flux Dev Kontext FP8",
                repo="Comfy-Org/flux1-kontext-dev_ComfyUI",
                filename="split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors",
                dest_subdir="models/diffusion_models/flux",
                size="11.9 GB",
            ),
            ModelSpec(
                name="CLIP-L / ViT-L-14",
                repo="zer0int/CLIP-GmP-ViT-L-14",
                filename="ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors",
                dest_subdir="models/text_encoders/flux",
                size="~900 MB",
            ),
            ModelSpec(
                name="T5-XXL FP16",
                repo="comfyanonymous/flux_text_encoders",
                filename="t5xxl_fp16.safetensors",
                dest_subdir="models/text_encoders/flux",
                size="9.8 GB",
            ),
            ModelSpec(
                name="Flux VAE",
                repo="black-forest-labs/FLUX.1-dev",
                filename="ae.safetensors",
                dest_subdir="models/vae/flux",
                size="340 MB",
                requires_agreement="https://huggingface.co/black-forest-labs/FLUX.1-dev",
            ),
            ModelSpec(
                name="Flux Turbo LoRA",
                repo="fal/FLUX.2-dev-Turbo",
                filename="flux.2-turbo-lora.safetensors",
                dest_subdir="models/loras/flux",
                size="~500 MB",
                rename_to="Flux1DevTurbo.safetensors",
            ),
            ModelSpec(
                name="EV -4 LoRA",
                repo="Sumitc13/Flux-Kontext-exposure-control-LoRAs",
                filename="ev-4.safetensors",
                dest_subdir="models/loras/flux",
                size="~330 MB",
                rename_to="evminus4.safetensors",
            ),
            ModelSpec(
                name="EV -2 LoRA",
                repo="Sumitc13/Flux-Kontext-exposure-control-LoRAs",
                filename="ev-2.safetensors",
                dest_subdir="models/loras/flux",
                size="~330 MB",
                rename_to="evminus2.safetensors",
            ),
            ModelSpec(
                name="EV +2 LoRA",
                repo="Sumitc13/Flux-Kontext-exposure-control-LoRAs",
                filename="ev+2.safetensors",
                dest_subdir="models/loras/flux",
                size="~330 MB",
                rename_to="evplus2.safetensors",
            ),
            ModelSpec(
                name="EV +4 LoRA",
                repo="Sumitc13/Flux-Kontext-exposure-control-LoRAs",
                filename="ev+4.safetensors",
                dest_subdir="models/loras/flux",
                size="~330 MB",
                rename_to="evplus4.safetensors",
            ),
        ],
    )

    # ── Module 08 — Image to 3D ──────────────────────────────────────────────
    catalogue["08"] = ModuleSpec(
        label="Module 08",
        name="Image to 3D",
        models=[
            ModelSpec(
                name="TRELLIS.2-4B",
                repo="microsoft/TRELLIS.2-4B",
                filename="",
                dest_subdir="models/microsoft/TRELLIS.2-4B",
                size="~16 GB",
                full_repo=True,
            ),
            ModelSpec(
                name="DINOv3 ViT-L/16",
                repo="facebook/dinov3-vitl16-pretrain-lvd1689m",
                filename="",
                dest_subdir="models/facebook/dinov3-vitl16-pretrain-lvd1689m",
                size="~1 GB",
                full_repo=True,
                requires_agreement="https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m",
            ),
            ModelSpec(
                name="TRELLIS-image-large (shape decoder)",
                repo="microsoft/TRELLIS-image-large",
                filename="",
                dest_subdir="models/microsoft/TRELLIS-image-large",
                size="~3 GB",
                full_repo=True,
            ),
        ],
        manual_notes=[
            "DINOv3 is a gated model — requires a HuggingFace account with Meta's",
            "data agreement accepted at:",
            "  https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m",
            "Then log in before downloading: huggingface-cli login",
        ],
    )

    # ── Module 09 — Image Cut Out Time to Move ──────────────────────────────
    catalogue["09"] = ModuleSpec(
        label="Module 09",
        name="Image Cut Out Time to Move",
        models=[
            WAN_VAE,
            WAN_TEXT_ENCODER,
            ModelSpec(
                name="Wan2.2 I2V A14B HIGH BF16",
                repo="Kijai/WanVideo_comfy",
                filename="Wan2_2-I2V-A14B-HIGH_bf16.safetensors",
                dest_subdir="models/diffusion_models",
                size="~28 GB",
            ),
            ModelSpec(
                name="Wan2.2 I2V A14B LOW BF16",
                repo="Kijai/WanVideo_comfy",
                filename="Wan2_2-I2V-A14B-LOW_bf16.safetensors",
                dest_subdir="models/diffusion_models",
                size="~28 GB",
            ),
            ModelSpec(
                name="Wan2.2 Pusa V1 HIGH LoRA",
                repo="Kijai/WanVideo_comfy",
                filename="Pusa/Wan22_PusaV1_lora_HIGH_resized_dynamic_avg_rank_98_bf16.safetensors",
                dest_subdir="models/loras",
                size="~950 MB",
                revision="090d264d1fd6f4f36921f62ddddfe3d43b1cb5f6",
            ),
            ModelSpec(
                name="Wan2.2 Pusa V1 LOW LoRA",
                repo="Kijai/WanVideo_comfy",
                filename="Pusa/Wan22_PusaV1_lora_LOW_resized_dynamic_avg_rank_98_bf16.safetensors",
                dest_subdir="models/loras",
                size="~970 MB",
            ),
            ModelSpec(
                name="Wan2.2 Fun A14B InP HIGH HPS LoRA",
                repo="alibaba-pai/Wan2.2-Fun-Reward-LoRAs",
                filename="Wan2.2-Fun-A14B-InP-high-noise-HPS2.1.safetensors",
                dest_subdir="models/loras",
                size="~860 MB",
            ),
            ModelSpec(
                name="Wan2.2 Fun A14B InP LOW HPS LoRA",
                repo="alibaba-pai/Wan2.2-Fun-Reward-LoRAs",
                filename="Wan2.2-Fun-A14B-InP-low-noise-HPS2.1.safetensors",
                dest_subdir="models/loras",
                size="~860 MB",
            ),
            ModelSpec(
                name="Wan2.2 I2V A14B Distill 4-step (lightx2v)",
                repo="lightx2v/Wan2.2-Distill-Models",
                filename="wan2.2_i2v_A14b_high_noise_lightx2v_4step.safetensors",
                dest_subdir="models/loras",
                size="~29 GB",
                rename_to="wan2.2_i2v_A14b_high_noise_lora_rank64_lightx2v_4step.safetensors",
            ),
            ModelSpec(
                name="Wan2.2 A14B T2V LOW Lightning LoRA",
                repo="Kijai/WanVideo_comfy",
                filename="LoRAs/Wan22-Lightning/Wan22_A14B_T2V_LOW_Lightning_4steps_lora_250928_rank64_fp16.safetensors",
                dest_subdir="models/loras",
                size="~615 MB",
            ),
            ModelSpec(
                name="SAM3 Model",
                repo="1038lab/sam3",
                filename="sam3.pt",
                dest_subdir="models/sam3",
                size="~3.4 GB",
            ),
            ModelSpec(
                name="Qwen Flymy Realism LoRA",
                repo="flymy-ai/qwen-image-realism-lora",
                filename="flymy_realism.safetensors",
                dest_subdir="models/loras",
                size="~500 MB",
                rename_to="Qwen-flymy_realism.safetensors",
            ),
        ],
    )

    # ── Module 10 — Video to Video ───────────────────────────────────────────
    catalogue["10"] = ModuleSpec(
        label="Module 10",
        name="Video to Video",
        models=[
            WAN_VAE,
            WAN_TEXT_ENCODER,
            ModelSpec(
                name="Wan2.2 T2V High Noise 14B FP16",
                repo="Comfy-Org/Wan_2.2_ComfyUI_Repackaged",
                filename="split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors",
                dest_subdir="models/diffusion_models",
                size="~28 GB",
            ),
            ModelSpec(
                name="Wan2.2 T2V Low Noise 14B FP16",
                repo="Comfy-Org/Wan_2.2_ComfyUI_Repackaged",
                filename="split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors",
                dest_subdir="models/diffusion_models",
                size="~28 GB",
            ),
            ModelSpec(
                name="Wan2.2 VACE Fun A14B High Noise",
                repo="alibaba-pai/Wan2.2-VACE-Fun-A14B",
                filename="high_noise_model/diffusion_pytorch_model.safetensors",
                dest_subdir="models/diffusion_models",
                size="~37 GB",
                rename_to="Wan2.2-VACE-Fun-A14B_high_noise_model.safetensors",
            ),
            ModelSpec(
                name="Wan2.2 VACE Fun A14B Low Noise",
                repo="alibaba-pai/Wan2.2-VACE-Fun-A14B",
                filename="low_noise_model/diffusion_pytorch_model.safetensors",
                dest_subdir="models/diffusion_models",
                size="~37 GB",
                rename_to="Wan2.2-VACE-Fun-A14B_low_noise_model.safetensors",
            ),
            ModelSpec(
                name="Lotus Depth D v1.1 FP16",
                repo="Kijai/lotus-comfyui",
                filename="lotus-depth-d-v-1-1-fp16.safetensors",
                dest_subdir="models/diffusion_models",
                size="~1.7 GB",
            ),
            ModelSpec(
                name="SD VAE ft-mse",
                repo="stabilityai/sd-vae-ft-mse-original",
                filename="vae-ft-mse-840000-ema-pruned.safetensors",
                dest_subdir="models/vae",
                size="~335 MB",
            ),
            ModelSpec(
                name="Wan2.1 T2V 14B Lightning LoRA",
                repo="Kijai/WanVideo_comfy",
                filename="Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors",
                dest_subdir="models/loras",
                size="~315 MB",
                revision="1d87de611cd3be0c10bf8e21fa965038018693e7",
            ),
            ModelSpec(
                name="4x-ClearRealityV1 Upscaler",
                repo="skbhadra/ClearRealityV1",
                filename="4x-ClearRealityV1.pth",
                dest_subdir="models/upscale_models",
                size="~9 MB",
            ),
        ],
    )

    # ── Bonus A — Texture Extraction ────────────────────────────────────────
    catalogue["bonus-a"] = ModuleSpec(
        label="Bonus A",
        name="Texture Extraction",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            ModelSpec(
                name="Extract Texture LoRA",
                repo="tarn59/extract_texture_qwen_image_edit_2509",
                filename="extract_texture_qwen_image_edit_2509.safetensors",
                dest_subdir="models/loras/qwen",
                size="500 MB",
            ),
        ],
    )

    # ── Bonus B — Texture to PBR ────────────────────────────────────────────
    catalogue["bonus-b"] = ModuleSpec(
        label="Bonus B",
        name="Texture to PBR",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            LOTUS_DEPTH_G,
            ModelSpec(
                name="Lotus Normal G",
                repo="Kijai/lotus-comfyui",
                filename="lotus-normal-g-v1-0.safetensors",
                dest_subdir="models/diffusion_models/lotus",
                size="~2 GB",
            ),
            ModelSpec(
                name="Lotus Normal D",
                repo="Kijai/lotus-comfyui",
                filename="lotus-normal-d-v1-0.safetensors",
                dest_subdir="models/diffusion_models/lotus",
                size="~2 GB",
            ),
            LOTUS_VAE,
            ModelSpec(
                name="4x-UltraSharp Upscaler",
                repo="Kim2091/UltraSharp",
                filename="4x-UltraSharp.pth",
                dest_subdir="models/upscale_models",
                size="~65 MB",
            ),
        ],
    )

    return catalogue


# ---------------------------------------------------------------------------
# Download logic
# ---------------------------------------------------------------------------

def _hf_expected_size(repo: str, filename: str, revision: Optional[str] = None) -> Optional[int]:
    """Return HF's reported byte count for a single file, or None if unavailable."""
    try:
        url = hf_hub_url(repo_id=repo, filename=filename, revision=revision or "main")
        meta = get_hf_file_metadata(url)
        return meta.size
    except Exception:
        return None


def hf_download_file(repo: str, filename: str, local_dir: Path,
                     revision: Optional[str] = None) -> bool:
    """
    Download a single file from a HuggingFace repo using the Python API.
    Moves the file to a flat location in local_dir (strips repo subdirectories).
    Retries up to _DOWNLOAD_MAX_RETRIES times with exponential backoff.
    Returns True on success.
    """
    for attempt in range(1, _DOWNLOAD_MAX_RETRIES + 1):
        try:
            if attempt > 1:
                print(f"    Fetching (attempt {attempt}/{_DOWNLOAD_MAX_RETRIES}): {repo} / {filename}")
            else:
                print(f"    Fetching: {repo} / {filename}")
            hf_hub_download(
                repo_id=repo,
                filename=filename,
                local_dir=str(local_dir),
                revision=revision if revision else None,
            )
            # hf_hub_download preserves the repo's directory structure inside
            # local_dir (e.g. split_files/diffusion_models/foo.safetensors).
            # Move the file to local_dir/foo.safetensors (flat).
            downloaded = local_dir / filename
            target = local_dir / Path(filename).name
            if downloaded != target and downloaded.exists():
                downloaded.rename(target)
                _remove_empty_parents(downloaded.parent, local_dir)
            return True
        except Exception as e:
            print(f"    [ERROR] {e}")
            if attempt < _DOWNLOAD_MAX_RETRIES:
                wait = 5 * attempt
                print(f"    Retrying in {wait}s...")
                time.sleep(wait)
            else:
                print(f"    All {_DOWNLOAD_MAX_RETRIES} attempts failed for {filename}.")
                return False
    return False


def _remove_empty_parents(path: Path, stop_at: Path) -> None:
    """Remove empty directories up to (but not including) stop_at."""
    while path != stop_at and path.exists():
        try:
            path.rmdir()
            path = path.parent
        except OSError:
            break


def hf_download_repo(repo: str, local_dir: Path) -> bool:
    """
    Download an entire HuggingFace repo using the Python API.
    Retries up to _DOWNLOAD_MAX_RETRIES times with exponential backoff.
    Returns True on success.
    """
    for attempt in range(1, _DOWNLOAD_MAX_RETRIES + 1):
        try:
            if attempt > 1:
                print(f"    Fetching repo (attempt {attempt}/{_DOWNLOAD_MAX_RETRIES}): {repo}")
            else:
                print(f"    Fetching repo: {repo}")
            snapshot_download(
                repo_id=repo,
                local_dir=str(local_dir),
            )
            return True
        except Exception as e:
            print(f"    [ERROR] {e}")
            if attempt < _DOWNLOAD_MAX_RETRIES:
                wait = 5 * attempt
                print(f"    Retrying in {wait}s...")
                time.sleep(wait)
            else:
                print(f"    All {_DOWNLOAD_MAX_RETRIES} attempts failed for repo {repo}.")
                return False
    return False


def dest_file_path(comfyui_root: Path, model: ModelSpec) -> Optional[Path]:
    """
    Return the expected final path of the model on disk (after any rename).
    Returns None for full_repo downloads (no single file).
    """
    if model.full_repo:
        return None
    dest_dir = comfyui_root / model.dest_subdir
    final_name = model.rename_to if model.rename_to else Path(model.filename).name
    return dest_dir / final_name


def download_model(comfyui_root: Path, model: ModelSpec) -> str:
    """
    Download a single model. Returns one of: "downloaded", "skipped", "failed".
    """
    # ── Agreement gate ─────────────────────────────────────────────────────
    if model.requires_agreement:
        print()
        print(f"  [ACTION REQUIRED] {model.name} requires accepting a data agreement.")
        print(f"  1. Visit: {model.requires_agreement}")
        print(f"  2. Log in to HuggingFace and click 'Agree and access repository'")
        print(f"  3. Then re-run this installer")
        print()
        try:
            answer = input(f"  Have you already accepted the agreement? [Y/N]: ").strip().lower()
        except EOFError:
            answer = ""
        if answer != "y":
            print(f"  Skipping {model.name} — accept the agreement and re-run to download.")
            return "skipped"

    dest_dir = comfyui_root / model.dest_subdir
    dest_dir.mkdir(parents=True, exist_ok=True)

    # ── Full repo download (no single-file check) ──────────────────────────
    if model.full_repo:
        print(f"  Downloading full repo: {model.repo}")
        print(f"    Size: {model.size}")
        print(f"    Destination: {dest_dir}")
        ok = hf_download_repo(model.repo, dest_dir)
        return "downloaded" if ok else "failed"

    # ── Single file download ───────────────────────────────────────────────
    final_path = dest_file_path(comfyui_root, model)

    if final_path and final_path.exists():
        actual = final_path.stat().st_size
        if actual < _DOWNLOAD_MIN_SIZE:
            print(f"  [WARN] Incomplete file ({actual} bytes), re-downloading: {final_path.name}")
            final_path.unlink()
        else:
            expected = _hf_expected_size(model.repo, model.filename, model.revision)
            if expected is not None and actual != expected:
                print(f"  [WARN] Size mismatch ({actual:,} of {expected:,} bytes), re-downloading: {final_path.name}")
                final_path.unlink()
            else:
                print(f"  [SKIP] Already exists: {final_path.relative_to(comfyui_root)}")
                return "skipped"

    # Also check if the pre-rename file already exists (edge case)
    base_name = Path(model.filename).name
    pre_rename_path = dest_dir / base_name
    if model.rename_to and pre_rename_path.exists():
        print(f"  [RENAME] Found pre-rename file, renaming to {model.rename_to}")
        pre_rename_path.rename(final_path)
        return "downloaded"

    print(f"  Downloading: {model.name}")
    print(f"    Repo:        {model.repo}")
    print(f"    File:        {model.filename}")
    print(f"    Size:        {model.size}")
    print(f"    Destination: {dest_dir}")
    print(f"    (Progress bar may not show when output is piped — this is normal. Please wait...)")

    ok = hf_download_file(model.repo, model.filename, dest_dir, revision=model.revision)
    if ok:
        print(f"    Complete: {model.name}")
    if not ok:
        print(f"  [FAILED] Download failed for {model.name}")
        return "failed"

    # Handle rename
    if model.rename_to:
        # huggingface-cli may place the file in a subdirectory matching the
        # repo path structure (e.g. vae/diffusion_pytorch_model.safetensors).
        # Try the direct location first, then walk dest_dir to find it.
        candidate = dest_dir / base_name
        if not candidate.exists():
            # Search for the file inside dest_dir (one level deep)
            for sub in dest_dir.rglob(base_name):
                candidate = sub
                break

        if candidate.exists():
            target = dest_dir / model.rename_to
            print(f"  Renaming {candidate.name} -> {model.rename_to}")
            candidate.rename(target)
        else:
            print(f"  [WARN] Could not find {base_name} to rename inside {dest_dir}")

    return "downloaded"


# ---------------------------------------------------------------------------
# Module clean
# ---------------------------------------------------------------------------

def clean_modules(comfyui_root: Path, selected_keys: list, catalogue: dict) -> None:
    """Remove model files that belong exclusively to the selected modules.

    Files shared with other modules are skipped to avoid breaking them.
    Custom nodes are not removed — they are small and often shared.
    """
    other_keys = [k for k in catalogue if k not in selected_keys]

    # Build sets of (dest_subdir, final_filename) for cleaning vs keeping.
    # Keyed on dest location, not repo URL — two entries writing the same file
    # on disk will share a key and be treated as shared (correct behavior).
    def model_key(m: ModelSpec):
        if m.full_repo:
            return ("full_repo", m.dest_subdir)
        name = m.rename_to if m.rename_to else Path(m.filename).name
        return ("file", m.dest_subdir, name)

    to_clean = set()
    for key in selected_keys:
        for m in catalogue[key].models:
            to_clean.add(model_key(m))

    keep = set()
    for key in other_keys:
        for m in catalogue[key].models:
            keep.add(model_key(m))

    # Build preview list for confirmation prompt
    preview = []
    for key in selected_keys:
        for m in catalogue[key].models:
            mk = model_key(m)
            if mk in keep:
                continue
            if m.full_repo:
                target = comfyui_root / m.dest_subdir
                if target.exists():
                    preview.append(f"  dir:  {m.dest_subdir}/")
            else:
                path = dest_file_path(comfyui_root, m)
                if path and path.exists():
                    preview.append(f"  file: {path.relative_to(comfyui_root)}")

    if not preview:
        print("\n  Nothing to remove — files not found or all shared with other modules.")
        return

    print(f"\n  The following will be permanently deleted ({len(preview)} item(s)):")
    for p in preview:
        print(p)
    print()
    try:
        confirm = input("  Type 'yes' to confirm deletion: ").strip().lower()
    except EOFError:
        confirm = ""
    if confirm != "yes":
        print("  Aborted — nothing deleted.")
        return
    print()

    removed = 0
    skipped_shared = []
    not_found = 0

    for key in selected_keys:
        spec = catalogue[key]
        print()
        print("=" * 70)
        print(f"  Cleaning {spec.label}: {spec.name}")
        print("=" * 70)

        seen = set()
        for m in spec.models:
            mk = model_key(m)
            if mk in seen:
                continue
            seen.add(mk)

            if mk in keep:
                label = m.dest_subdir if m.full_repo else (m.rename_to or Path(m.filename).name)
                skipped_shared.append(label)
                print(f"  [SHARED] Keeping (used by other modules): {label}")
                continue

            if m.full_repo:
                target = comfyui_root / m.dest_subdir
                if target.exists() and target.is_dir():
                    shutil.rmtree(target)
                    print(f"  removed dir: {m.dest_subdir}")
                    removed += 1
                else:
                    not_found += 1
            else:
                path = dest_file_path(comfyui_root, m)
                if path and path.exists():
                    path.unlink()
                    print(f"  removed: {path.relative_to(comfyui_root)}")
                    removed += 1
                else:
                    not_found += 1

    print()
    print("=" * 70)
    print("  CLEAN SUMMARY")
    print("=" * 70)
    print(f"\n  {removed} file(s) / dir(s) removed.")
    if not_found:
        print(f"  {not_found} not found (already removed or never downloaded).")
    if skipped_shared:
        print(f"  {len(skipped_shared)} skipped — shared with other modules:")
        for label in skipped_shared:
            print(f"    ~ {label}")
    print()


# ---------------------------------------------------------------------------
# Ollama detection
# ---------------------------------------------------------------------------

def _detect_ollama() -> tuple[bool, bool]:
    """Return (ollama_installed, gemma3_pulled).

    Probes PATH first, then the known Windows install path, so detection works
    even when the Ollama installer hasn't refreshed the current session's PATH.
    Calls `ollama list` with a 10-second timeout; if the daemon isn't running
    we can confirm the binary exists but can't confirm the model state.
    """
    exe = shutil.which("ollama")
    if not exe:
        # Fallback: Windows default install location
        win_path = os.path.expandvars(r"%LOCALAPPDATA%\Programs\Ollama\ollama.exe")
        if os.path.exists(win_path):
            exe = win_path

    if not exe:
        return False, False

    try:
        result = subprocess.run(
            [exe, "list"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            gemma3_pulled = any(
                line.split()[0].startswith("gemma3")
                for line in result.stdout.splitlines()
                if line.strip()
            )
            return True, gemma3_pulled
        # Daemon not running — binary exists but model state unknown
        return True, False
    except (subprocess.TimeoutExpired, OSError):
        return True, False


# ---------------------------------------------------------------------------
# Module runner
# ---------------------------------------------------------------------------

def run_module(comfyui_root: Path, module_key: str, spec: ModuleSpec,
               summary: dict) -> None:
    """Process one module."""
    print()
    print("=" * 70)
    print(f"  {spec.label}: {spec.name}")
    print("=" * 70)

    # Modules with a hard skip (e.g. Module 01 / Ollama)
    if spec.skip:
        print(f"  [SKIP] {spec.skip_reason}")
        print(f"  --> Install Ollama: https://ollama.com/download")
        print(f"  --> Then run: ollama pull gemma3")
        print(f"  --> Once done, launch ComfyUI — no further downloads needed for this module.")
        summary["manual"].append(f"{spec.label} ({spec.name}): {spec.skip_reason}")
        return

    # Modules with no downloadable models but with notes (e.g. Module 04)
    if not spec.models:
        print(f"  No downloadable models for {spec.label}.")
        for note in spec.manual_notes:
            print(f"  NOTE: {note}")
        if spec.manual_notes:
            summary["manual"].append(
                f"{spec.label} ({spec.name}): " + " | ".join(spec.manual_notes)
            )
        return

    # Deduplicate models within this module by (repo, filename) to avoid
    # re-downloading shared models listed multiple times in a module.
    seen = set()
    unique_models = []
    for m in spec.models:
        key = (m.repo, m.filename)
        if key not in seen:
            seen.add(key)
            unique_models.append(m)

    for model in unique_models:
        result = download_model(comfyui_root, model)
        entry = f"{spec.label} / {model.name} ({model.size})"
        if result == "downloaded":
            summary["downloaded"].append(entry)
        elif result == "skipped":
            summary["skipped"].append(entry)
        else:
            summary["failed"].append(entry)

    # Print any manual notes after downloads.
    # For notes referencing Ollama/Gemma3, check whether they're already
    # satisfied before adding them to the manual action summary.
    if spec.manual_notes:
        ollama_notes = [n for n in spec.manual_notes
                        if "ollama" in n.lower() or "gemma3" in n.lower()]
        other_notes  = [n for n in spec.manual_notes if n not in ollama_notes]
        remaining = list(other_notes)

        if ollama_notes:
            ollama_ok, gemma3_ok = _detect_ollama()
            if ollama_ok:
                print(f"  Ollama: already installed.")
            else:
                print(f"  Ollama: not detected — install from https://ollama.com/download")
                remaining.append("Install Ollama: https://ollama.com/download")
            if gemma3_ok:
                print(f"  Gemma3: already pulled.")
            elif ollama_ok:
                print(f"  Gemma3: not pulled — run: ollama pull gemma3")
                remaining.append("Run: ollama pull gemma3")
            else:
                remaining.append("Run: ollama pull gemma3 (after installing Ollama)")

        if remaining:
            print()
            print(f"  Manual action required for {spec.label}:")
            for note in remaining:
                print(f"    * {note}")
            summary["manual"].append(
                f"{spec.label} ({spec.name}): " + " | ".join(remaining)
            )
        else:
            print(f"  {spec.label}: Ollama + Gemma3 already set up.")


# ---------------------------------------------------------------------------
# Argument parsing and module selection
# ---------------------------------------------------------------------------

ALL_MODULE_KEYS = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
                   "bonus-a", "bonus-b"]

ALIAS_MAP = {
    # Accept "bonus_a", "bonusa", "bonus-a", "ba", etc.
    "bonus_a": "bonus-a",
    "bonusa":  "bonus-a",
    "ba":      "bonus-a",
    "bonus_b": "bonus-b",
    "bonusb":  "bonus-b",
    "bb":      "bonus-b",
}


def parse_modules(raw: str) -> list:
    """
    Accept "all" or comma-separated list like "01,02,bonus-a".
    Returns a list of canonical module keys.
    """
    if raw.strip().lower() == "all":
        return ALL_MODULE_KEYS

    keys = []
    for token in raw.split(","):
        token = token.strip().lower()
        token = ALIAS_MAP.get(token, token)
        # Zero-pad single digits
        if token.isdigit():
            token = token.zfill(2)
        if token not in ALL_MODULE_KEYS:
            print(f"[WARN] Unknown module '{token}' — skipping.", file=sys.stderr)
            continue
        keys.append(token)
    return keys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download ComfyUI models for the generative AI workflows course.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Download all modules
  python download_models.py --comfyui /opt/ComfyUI

  # Download specific modules
  python download_models.py --comfyui /opt/ComfyUI --modules 02,03,05

  # Download a single module
  python download_models.py --comfyui /opt/ComfyUI --modules 10

  # Download bonus modules
  python download_models.py --comfyui /opt/ComfyUI --modules bonus-a,bonus-b

  # Remove model files for a module (shared models are kept)
  python download_models.py --comfyui /opt/ComfyUI --modules 04 --clean
""",
    )
    parser.add_argument(
        "--comfyui",
        required=True,
        metavar="PATH",
        help="Path to the ComfyUI root directory (the folder containing 'models/').",
    )
    parser.add_argument(
        "--modules",
        default="all",
        metavar="MODULES",
        help=(
            "Comma-separated module numbers to download, e.g. '01,02,bonus-a'. "
            "Use 'all' to download everything (default: all)."
        ),
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help=(
            "Remove downloaded model files for the specified modules instead of downloading. "
            "Files shared with other modules are kept. Custom nodes are not removed."
        ),
    )
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    args = parse_args()

    # Warn if run directly — install.bat / install.sh also installs custom nodes.
    # Running this script alone skips node installation.
    if sys.stdout.isatty():
        print()
        print("NOTE: download_models.py only downloads model weights.")
        print("      To install custom nodes AND download models in one step, use:")
        print("        Windows: install.bat C:\\path\\to\\ComfyUI --modules <modules>")
        print("        Linux:   bash install.sh /path/to/ComfyUI --modules <modules>")
        print()

    comfyui_root = Path(args.comfyui).expanduser().resolve()
    if not comfyui_root.exists():
        print(f"[ERROR] ComfyUI root does not exist: {comfyui_root}", file=sys.stderr)
        sys.exit(1)

    if args.clean and args.modules == "all":
        print("[ERROR] --clean requires an explicit --modules list.", file=sys.stderr)
        print("        Specify which modules to clean, e.g. --modules 04", file=sys.stderr)
        print("        Use 'all' only intentionally — it removes every downloaded model.", file=sys.stderr)
        sys.exit(1)

    selected_keys = parse_modules(args.modules)
    if not selected_keys:
        print("[ERROR] No valid modules selected.", file=sys.stderr)
        sys.exit(1)

    catalogue = build_module_catalogue()

    if args.clean:
        print(f"\nComfyUI root : {comfyui_root}")
        print(f"Clean modules: {', '.join(selected_keys)}")
        clean_modules(comfyui_root, selected_keys, catalogue)
        return

    # Check HuggingFace login status
    if get_token():
        print("HuggingFace: logged in (faster downloads enabled)")
    else:
        print("HuggingFace: not logged in — downloads may be slower or rate-limited.")
        print("  To log in: huggingface-cli login")
        print()

    summary = {
        "downloaded": [],
        "skipped":    [],
        "failed":     [],
        "manual":     [],
    }

    print(f"\nComfyUI root : {comfyui_root}")
    print(f"Modules      : {', '.join(selected_keys)}")

    for key in selected_keys:
        spec = catalogue[key]
        run_module(comfyui_root, key, spec, summary)

    # ── Summary ─────────────────────────────────────────────────────────────
    print()
    print("=" * 70)
    print("  SUMMARY")
    print("=" * 70)

    print(f"\nDownloaded ({len(summary['downloaded'])}):")
    if summary["downloaded"]:
        for item in summary["downloaded"]:
            print(f"  + {item}")
    else:
        print("  (none)")

    print(f"\nSkipped — already exist ({len(summary['skipped'])}):")
    if summary["skipped"]:
        for item in summary["skipped"]:
            print(f"  = {item}")
    else:
        print("  (none)")

    print(f"\nFailed ({len(summary['failed'])}):")
    if summary["failed"]:
        for item in summary["failed"]:
            print(f"  ! {item}")
    else:
        print("  (none)")

    print(f"\nRequires manual action ({len(summary['manual'])}):")
    if summary["manual"]:
        for item in summary["manual"]:
            print(f"  * {item}")
    else:
        print("  (none)")

    if summary["failed"]:
        print("\n[ERROR] Some downloads failed. Check output above for details.")
        sys.exit(1)
    else:
        print("\nDone.")


if __name__ == "__main__":
    main()
