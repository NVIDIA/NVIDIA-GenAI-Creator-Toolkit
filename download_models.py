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
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

try:
    from huggingface_hub import hf_hub_download, snapshot_download
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
    size="13.5 GB",
)

QWEN_TEXT_ENCODER = ModelSpec(
    name="Qwen 2.5 VL 7B Text Encoder",
    repo="Comfy-Org/Qwen-Image_ComfyUI",
    filename="split_files/text_encoders/qwen_2.5_vl_7b.safetensors",
    dest_subdir="models/text_encoders/qwen",
    size="14.5 GB",
)

QWEN_VAE = ModelSpec(
    name="Qwen Image VAE",
    repo="Comfy-Org/Qwen-Image_ComfyUI",
    filename="split_files/vae/qwen_image_vae.safetensors",
    dest_subdir="models/vae/qwen",
    size="170 MB",
)

QWEN_LIGHTNING_8STEP = ModelSpec(
    name="Qwen Lightning 8-step LoRA",
    repo="lightx2v/Qwen-Image-Lightning",
    filename="Qwen-Image-Lightning-8steps-V2.0.safetensors",
    dest_subdir="models/loras/qwen",
    size="500 MB",
)

OBJECT_REMOVER_LORA = ModelSpec(
    name="Object Remover LoRA",
    repo="lightx2v/Qwen-Image-Edit-Object-Remover",
    filename="Qwen-Image-Edit-2511-Object-Remover.safetensors",
    dest_subdir="models/loras",
    size="500 MB",
)

LOTUS_DEPTH = ModelSpec(
    name="Lotus Depth",
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


# ---------------------------------------------------------------------------
# Module catalogue
# ---------------------------------------------------------------------------

def build_module_catalogue() -> dict:
    """
    Returns a dict keyed by zero-padded module number string (e.g. "01", "02",
    "bonus-a", "bonus-b").  Values are ModuleSpec instances.
    """
    catalogue = {}

    # ── Module 01 — skipped (Ollama/Gemma3) ────────────────────────────────
    catalogue["01"] = ModuleSpec(
        label="Module 01",
        name="LLM Prompt Enhancer",
        skip=True,
        skip_reason=(
            "Module 01 uses Ollama for the Gemma3 LLM. "
            "Run: ollama pull gemma3"
        ),
        # The 4 HF models below exist but are listed for reference only;
        # the module is intentionally skipped per course design.
        models=[
            ModelSpec(
                name="Qwen Image 2512 BF16",
                repo="Comfy-Org/Qwen-Image_ComfyUI",
                filename="split_files/diffusion_models/qwen_image_2512_bf16.safetensors",
                dest_subdir="models/diffusion_models/qwen",
                size="13.5 GB",
            ),
            QWEN_TEXT_ENCODER,
            ModelSpec(
                name="Qwen Image VAE (2512 variant)",
                repo="Comfy-Org/Qwen-Image_ComfyUI",
                filename="split_files/vae/qwen_image_vae.safetensors",
                dest_subdir="models/vae/qwen",
                size="170 MB",
            ),
            ModelSpec(
                name="Qwen Lightning 8-step FP32 LoRA",
                repo="lightx2v/Qwen-Image-2512-Lightning",
                filename="Qwen-Image-2512-Lightning-8steps-V1.0-fp32.safetensors",
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
                size="13.5 GB",
            ),
            QWEN_TEXT_ENCODER,
            ModelSpec(
                name="Qwen Image Layered VAE",
                repo="Comfy-Org/Qwen-Image-Layered_ComfyUI",
                filename="split_files/vae/qwen_image_layered_vae.safetensors",
                dest_subdir="models/vae/qwen",
                size="170 MB",
            ),
            ModelSpec(
                name="Qwen Lightning 8-step LoRA (V2.0)",
                repo="lightx2v/Qwen-Image-Lightning",
                filename="Qwen-Image-Lightning-8steps-V2.0.safetensors",
                dest_subdir="models/loras/qwen",
                size="500 MB",
            ),
        ],
    )

    # ── Module 03 — Targeted Inpainting ─────────────────────────────────────
    catalogue["03"] = ModuleSpec(
        label="Module 03",
        name="Targeted Inpainting",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            OBJECT_REMOVER_LORA,
        ],
    )

    # ── Module 04 — Image to Gaussian Splat ─────────────────────────────────
    catalogue["04"] = ModuleSpec(
        label="Module 04",
        name="Image to Gaussian Splat",
        models=[],
        manual_notes=[
            "Module 04 uses SHARP, which is bundled with the ComfyUI-Sharp custom node.",
            "Install the ComfyUI-Sharp node pack and the model downloads automatically.",
            "No manual model download is required.",
        ],
    )

    # ── Module 05 — Gaussian Splat SceneFill ────────────────────────────────
    catalogue["05"] = ModuleSpec(
        label="Module 05",
        name="Gaussian Splat SceneFill",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            ModelSpec(
                name="Qwen Sharp Gaussian Splat LoRA",
                repo="dx8152/Qwen-Image-Edit-2511-Gaussian-Splash",
                filename="Qwen2511SharpGaussianSplat.safetensors",
                dest_subdir="models/loras",
                size="500 MB",
            ),
        ],
    )

    # ── Module 06 — Equirectangular Outpainting ──────────────────────────────
    # The MikMumpitz 360 LoRA is a DLI course asset — no public download.
    catalogue["06"] = ModuleSpec(
        label="Module 06",
        name="Equirectangular Outpainting",
        models=[
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            QWEN_LIGHTNING_8STEP,
            OBJECT_REMOVER_LORA,
        ],
        manual_notes=[
            "Module 06 also requires the MikMumpitz 360 LoRA.",
            "This is a DLI course asset and is not publicly downloadable.",
            "Enroll in NVIDIA DLI course DLIT81948 to access it.",
            "Place it manually at: models/loras/  (filename: MikMumpitz360.safetensors or as distributed).",
        ],
    )

    # ── Module 07 — Panorama to HDRI ────────────────────────────────────────
    # EV LoRAs are DLI-gated; Flux models are public.
    catalogue["07"] = ModuleSpec(
        label="Module 07",
        name="Panorama to HDRI",
        models=[
            ModelSpec(
                name="Flux Dev Kontext FP8",
                repo="Comfy-Org/flux1-kontext-dev_ComfyUI",
                filename="split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors",
                dest_subdir="models/diffusion_models",
                size="11.9 GB",
            ),
            ModelSpec(
                name="CLIP-L / ViT-L-14",
                repo="comfyanonymous/flux_text_encoders",
                filename="ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors",
                dest_subdir="models/text_encoders",
                size="250 MB",
            ),
            ModelSpec(
                name="T5-XXL FP16",
                repo="comfyanonymous/flux_text_encoders",
                filename="t5xxl_fp16.safetensors",
                dest_subdir="models/text_encoders",
                size="9.8 GB",
            ),
            ModelSpec(
                name="Flux VAE",
                repo="black-forest-labs/FLUX.1-dev",
                filename="ae.safetensors",
                dest_subdir="models/vae",
                size="340 MB",
            ),
            ModelSpec(
                name="Flux Turbo LoRA",
                repo="jasperai/Flux.1-dev-FastPass",
                filename="Flux1DevTurbo.safetensors",
                dest_subdir="models/loras",
                size="500 MB",
            ),
        ],
        manual_notes=[
            "Module 07 EV LoRAs (EV +4, +2, -2, -4) are DLI course assets.",
            "They are NOT publicly downloadable — enroll in NVIDIA DLI course DLIT81948.",
            "Place them manually at: models/loras/  once you have lab access.",
            "Note: Flux.1-dev requires a HuggingFace login (run: huggingface-cli login).",
            "Note: Flux.1-dev is subject to the Black Forest Labs Non-Commercial License.",
        ],
    )

    # ── Module 08 — Trellis2 3D Asset Gen ───────────────────────────────────
    catalogue["08"] = ModuleSpec(
        label="Module 08",
        name="Trellis2 3D Asset Gen",
        models=[
            ModelSpec(
                name="Trellis2 (JeffreyXiang/TRELLIS-image-large)",
                repo="JeffreyXiang/TRELLIS-image-large",
                filename="",               # full repo download
                dest_subdir="models/trellis2",
                size="15–20 GB",
                full_repo=True,
            ),
        ],
    )

    # ── Module 09 — Cutout Animation to Video ───────────────────────────────
    catalogue["09"] = ModuleSpec(
        label="Module 09",
        name="Cutout Animation to Video (Wan TTM)",
        models=[
            ModelSpec(
                name="Wan2.2 I2V 480P (full repo)",
                repo="Wan-AI/Wan2.2-I2V-14B-480P",
                filename="",
                dest_subdir="models/video/wan",
                size="~28 GB (includes text encoder + VAE)",
                full_repo=True,
            ),
            QWEN_EDIT_DIFFUSION,
            QWEN_TEXT_ENCODER,
            QWEN_VAE,
            ModelSpec(
                name="Qwen Edit Lightning 4-step BF16 LoRA",
                repo="lightx2v/Qwen-Image-Edit-2511-Lightning",
                filename="Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors",
                dest_subdir="models/loras/qwen",
                size="500 MB",
            ),
            ModelSpec(
                name="Qwen Flymy Realism LoRA",
                repo="flymy-ai/qwen-image-realism-lora",
                filename="flymy_realism.safetensors",
                dest_subdir="models/loras/qwen",
                size="500 MB",
                rename_to="Qwen-flymy_realism.safetensors",
            ),
            ModelSpec(
                name="SAM2 Hiera Tiny",
                repo="Kijai/sam2-safetensors",
                filename="sam2_hiera_tiny.safetensors",
                dest_subdir="models/sam2",
                size="~150 MB",
            ),
        ],
    )

    # ── Module 10 — Playblast to Video ──────────────────────────────────────
    catalogue["10"] = ModuleSpec(
        label="Module 10",
        name="Playblast to Video (Wan VACE)",
        models=[
            ModelSpec(
                name="Wan2.2 Fun VACE (full repo)",
                repo="Wan-AI/Wan2.2-Fun-14B-VACE",
                filename="",
                dest_subdir="models/video/wan",
                size="~28 GB (includes text encoder + VAE)",
                full_repo=True,
            ),
            LOTUS_DEPTH,
            LOTUS_VAE,
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
            LOTUS_DEPTH,
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
        manual_notes=[
            "Bonus B also uses Marigold models (Appearance + Light).",
            "These download automatically on first run via the ComfyUI-Marigold node.",
            "No manual download required for Marigold.",
        ],
    )

    return catalogue


# ---------------------------------------------------------------------------
# Download logic
# ---------------------------------------------------------------------------

def hf_download_file(repo: str, filename: str, local_dir: Path) -> bool:
    """
    Download a single file from a HuggingFace repo using the Python API.
    Returns True on success.
    """
    try:
        print(f"    Fetching: {repo} / {filename}")
        hf_hub_download(
            repo_id=repo,
            filename=filename,
            local_dir=str(local_dir),
        )
        return True
    except Exception as e:
        print(f"    [ERROR] {e}")
        return False


def hf_download_repo(repo: str, local_dir: Path) -> bool:
    """
    Download an entire HuggingFace repo using the Python API.
    Returns True on success.
    """
    try:
        print(f"    Fetching repo: {repo}")
        snapshot_download(
            repo_id=repo,
            local_dir=str(local_dir),
        )
        return True
    except Exception as e:
        print(f"    [ERROR] {e}")
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

    ok = hf_download_file(model.repo, model.filename, dest_dir)
    if not ok:
        print(f"  [FAILED] huggingface-cli exited with error for {model.name}")
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

    # Print any manual notes after downloads
    if spec.manual_notes:
        print()
        print(f"  Manual action required for {spec.label}:")
        for note in spec.manual_notes:
            print(f"    * {note}")
        summary["manual"].append(
            f"{spec.label} ({spec.name}): " + " | ".join(spec.manual_notes)
        )


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
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    args = parse_args()

    comfyui_root = Path(args.comfyui).expanduser().resolve()
    if not comfyui_root.exists():
        print(f"[ERROR] ComfyUI root does not exist: {comfyui_root}", file=sys.stderr)
        sys.exit(1)

    selected_keys = parse_modules(args.modules)
    if not selected_keys:
        print("[ERROR] No valid modules selected.", file=sys.stderr)
        sys.exit(1)

    catalogue = build_module_catalogue()

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
