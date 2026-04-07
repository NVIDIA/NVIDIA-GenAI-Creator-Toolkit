#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# install.sh — ComfyUI custom node installer for comfyui-generative-ai-workflows
#
# Usage:
#   bash install.sh /path/to/ComfyUI
#   bash install.sh /path/to/ComfyUI --modules 02,03,08
#   bash install.sh /path/to/ComfyUI --modules all

set -euo pipefail

# Parse arguments
COMFYUI_DIR=""
MODULES=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --modules) MODULES="$2"; shift 2 ;;
    *) if [ -z "$COMFYUI_DIR" ]; then COMFYUI_DIR="$1"; fi; shift ;;
  esac
done
COMFYUI_DIR="${COMFYUI_DIR:-$(pwd)}"

NODES_DIR="$COMFYUI_DIR/custom_nodes"
NODE_COUNT=0
NODE_TOTAL=20

echo ""
echo "================================================================"
echo " ComfyUI Generative AI Workflows - Node Installer"
echo "================================================================"
echo ""

if [ ! -f "$COMFYUI_DIR/main.py" ]; then
  echo "ERROR: main.py not found at: $COMFYUI_DIR"
  echo ""
  echo "  Pass the ComfyUI root directory (the folder containing main.py):"
  echo "    bash install.sh /path/to/ComfyUI"
  exit 1
fi

echo "ComfyUI path: $COMFYUI_DIR"
echo ""

# Detect venv and use its pip/python, or fall back to system with a warning
if [ -n "${VIRTUAL_ENV:-}" ]; then
  PIP="$VIRTUAL_ENV/bin/pip"
  PYTHON="$VIRTUAL_ENV/bin/python"
  echo "Detected active venv - using $PIP"
elif [ -f "$COMFYUI_DIR/venv/bin/pip" ]; then
  PIP="$COMFYUI_DIR/venv/bin/pip"
  PYTHON="$COMFYUI_DIR/venv/bin/python"
  echo "Detected venv - using $PIP"
else
  PIP="pip"
  PYTHON="python3"
  echo "WARNING: No venv detected. If pip installs fail, activate your ComfyUI venv first:"
  echo "  source $COMFYUI_DIR/venv/bin/activate"
fi

echo "Installing custom nodes into: $NODES_DIR"
mkdir -p "$NODES_DIR"
echo ""

install_node() {
  local name="$1"
  local repo="$2"
  local branch="${3:-}"
  local dir="$NODES_DIR/$name"
  NODE_COUNT=$((NODE_COUNT + 1))

  if [ -d "$dir" ]; then
    echo "[$NODE_COUNT/$NODE_TOTAL] skip    $name (already installed)"
  else
    echo "[$NODE_COUNT/$NODE_TOTAL] install $name ..."
    if [ -n "$branch" ]; then
      git clone --depth 1 --branch "$branch" "$repo" "$dir"
    else
      git clone --depth 1 "$repo" "$dir"
    fi
    echo "        OK"
  fi

  if [ -f "$dir/requirements.txt" ]; then
    echo "        Installing Python requirements..."
    local pip_log
    pip_log=$(mktemp)
    if ! $PIP install -q --no-warn-script-location -r "$dir/requirements.txt" > "$pip_log" 2>&1; then
      echo "        [WARN] Some packages failed to install for $name"
      echo "               This is usually OK - ComfyUI Manager resolves missing deps on first run."
      echo "               To see details: cat $pip_log"
    fi
  fi
}

# --- Core ---
install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager"

# --- Modules 01 + 02: Qwen utilities ---
install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes"
install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"

# --- Module 01: LLM Prompt Enhancer ---
install_node "comfyui-ollama" "https://github.com/stavsap/comfyui-ollama"

# --- Modules 02-07, Bonus A+B: TextureAlchemy ---
install_node "ComfyUI-TextureAlchemy" "https://github.com/amtarr/ComfyUI-TextureAlchemy" "Sandbox"

# --- Modules 04 + 05: Gaussian Splat ---
install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp"
install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack"

# --- Module 08: Trellis2 3D ---
install_node "ComfyUI-TRELLIS2" "https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2"

# --- Module 09: Cutout Animation ---
install_node "comfy_nv_video_prep" "https://github.com/NVIDIA/comfy_nv_video_prep"
install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
install_node "ComfyUI_essentials" "https://github.com/cubiq/ComfyUI_essentials"
install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
install_node "comfyui-sam2" "https://github.com/neverbiasu/ComfyUI-SAM2"
install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"

# --- Module 10: Playblast to Video ---
install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere"
install_node "radiance" "https://github.com/fxtdstudios/radiance"

# --- Modules 10 + Bonus B: Lotus ---
install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus"

# --- Bonus B: Texture to PBR ---
install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold"

WORKFLOWS_DEST="$COMFYUI_DIR/user/default/workflows/creative-genai-workflows"
mkdir -p "$WORKFLOWS_DEST"
for workflow_dir in "$(dirname "$0")/workflows"/*/; do
  if [ -f "${workflow_dir}workflow.json" ]; then
    module_name="$(basename "$workflow_dir")"
    mkdir -p "$WORKFLOWS_DEST/$module_name"
    cp "${workflow_dir}workflow.json" "$WORKFLOWS_DEST/$module_name/workflow.json"
  fi
done
echo ""
echo "Workflows copied to: $WORKFLOWS_DEST"

if [ -n "$MODULES" ]; then
  echo ""
  echo "================================================================"
  echo " Downloading models for modules: $MODULES"
  echo "================================================================"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  $PYTHON "$SCRIPT_DIR/download_models.py" --comfyui "$COMFYUI_DIR" --modules "$MODULES"
fi

echo ""
echo "================================================================"
echo " Installation complete"
echo "================================================================"
echo ""
if [ -z "$MODULES" ]; then
  echo "Next steps:"
  echo "  1. Module 01 only — install Ollama: https://ollama.com/download"
  echo "     Then run: ollama pull gemma3"
  echo "  2. Download models for the modules you want to use:"
  echo "     python download_models.py --comfyui \"$COMFYUI_DIR\" --modules 02,03,08"
  echo "     (large models like Wan2.2 and Trellis2 take time -- do this before your session)"
  echo "  3. Launch ComfyUI: source venv/bin/activate && python main.py"
  echo "  4. Workflows are ready in ComfyUI under: Load > creative-genai-workflows"
else
  echo "Next steps:"
  echo "  1. Module 01 only — install Ollama: https://ollama.com/download"
  echo "     Then run: ollama pull gemma3"
  echo "  2. Launch ComfyUI: source venv/bin/activate && python main.py"
  echo "  3. Workflows are ready in ComfyUI under: Load > creative-genai-workflows"
fi
