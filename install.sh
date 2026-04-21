#!/usr/bin/env bash
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

# Detect venv/conda and use its pip/python, or fall back to system with a warning
if [ -n "${VIRTUAL_ENV:-}" ]; then
  PIP="$VIRTUAL_ENV/bin/pip"
  PYTHON="$VIRTUAL_ENV/bin/python"
  echo "Detected active venv - using $PIP"
elif [ -f "$COMFYUI_DIR/venv/bin/pip" ]; then
  PIP="$COMFYUI_DIR/venv/bin/pip"
  PYTHON="$COMFYUI_DIR/venv/bin/python"
  echo "Detected venv - using $PIP"
elif [ -n "${CONDA_PREFIX:-}" ]; then
  PIP="$CONDA_PREFIX/bin/pip"
  PYTHON="$CONDA_PREFIX/bin/python"
  echo "Detected active conda env - using $PYTHON"
elif [ -n "${CONDA_EXE:-}" ]; then
  CONDA_BASE_PYTHON="$(dirname "$(dirname "$CONDA_EXE")")/bin/python"
  if [ -f "$CONDA_BASE_PYTHON" ]; then
    PIP="$CONDA_BASE_PYTHON -m pip"
    PYTHON="$CONDA_BASE_PYTHON"
    echo "Detected conda base env - using $PYTHON"
  fi
else
  PIP="pip"
  PYTHON="python3"
  echo "WARNING: No venv or conda env found. Using system pip."
  echo "  Activate your environment first for reliable installs:"
  echo "    conda: conda activate <env>"
  echo "    venv:  source $COMFYUI_DIR/venv/bin/activate"
fi

# --- Python version check ---
PY_VER=$($PYTHON -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>/dev/null)
PY_OK=$($PYTHON -c "import sys; print(1 if sys.version_info>=(3,10) else 0)" 2>/dev/null)
echo "[check] Python: $PY_VER"
if [ "$PY_OK" != "1" ]; then
  echo ""
  echo "[WARNING] Python $PY_VER detected. ComfyUI requires Python 3.10 or higher."
  echo "          Your install may have issues. Consider upgrading Python."
  echo ""
fi

# --- ComfyUI version check ---
if [ -f "$COMFYUI_DIR/comfyui_version.py" ]; then
  COMFY_VER=$($PYTHON -c "import re; f=open('$COMFYUI_DIR/comfyui_version.py').read(); print(re.search(r'__version__\s*=\s*[\'\"]([\'\".]+)[\'\"]*',f).group(1))" 2>/dev/null || \
              grep -oP "(?<=__version__ = [\"'])[^\"']+" "$COMFYUI_DIR/comfyui_version.py")
  echo "[check] ComfyUI: $COMFY_VER"
  echo "        Tested against: 0.19.x — other versions may work but are not guaranteed."
else
  echo "[check] ComfyUI: version file not found (pre-0.19 or non-standard install)"
  echo "[WARNING] Could not detect ComfyUI version. Proceeding anyway."
fi
echo ""

# --- Install ComfyUI requirements (ensures alembic and other deps are present) ---
if [ -f "$COMFYUI_DIR/requirements.txt" ]; then
  echo ""
  echo "Installing ComfyUI requirements..."
  $PIP install -q -r "$COMFYUI_DIR/requirements.txt"
fi
# comfyui-frontend-package is required by recent ComfyUI versions but missing from some requirements.txt
$PIP install -q comfyui-frontend-package

# --- Ensure PyTorch is CUDA-enabled ---
if nvidia-smi > /dev/null 2>&1; then
  if ! $PYTHON -c "import torch; exit(0 if torch.cuda.is_available() else 1)" > /dev/null 2>&1; then
    echo ""
    echo "[torch] PyTorch does not have CUDA support. Reinstalling with CUDA (cu128)..."
    echo "[torch] This may take several minutes (downloading ~2.5 GB)..."
    $PIP install --force-reinstall torch torchvision torchaudio --index-url "https://download.pytorch.org/whl/cu128"
    echo "[torch] Done. Restart ComfyUI to pick up the new torch."
  fi
fi

install_node() {
  local name="$1"
  local repo="$2"
  local branch="${3:-}"
  local dir="$NODES_DIR/$name"
  NODE_COUNT=$((NODE_COUNT + 1))

  if [ -d "$dir" ]; then
    echo "  [$NODE_COUNT] skip    $name (already installed)"
  else
    echo "  [$NODE_COUNT] install $name ..."
    if [ -n "$branch" ]; then
      git clone --depth 1 --branch "$branch" "$repo" "$dir"
    else
      git clone --depth 1 "$repo" "$dir"
    fi
    echo "           OK"
  fi

  if [ -f "$dir/requirements.txt" ]; then
    echo "           Installing Python requirements..."
    local pip_log
    pip_log=$(mktemp)
    if ! $PIP install -q --no-warn-script-location -r "$dir/requirements.txt" > "$pip_log" 2>&1; then
      echo "           [WARN] Some packages failed to install for $name"
      echo "                  This is usually OK - ComfyUI Manager resolves missing deps on first run."
      echo "                  To see details: cat $pip_log"
    fi
  fi
}

# Helper: returns 0 if a module number is in the selected list
module_selected() {
  local num="$1"
  [ -z "$MODULES" ] && return 1
  [ "${MODULES,,}" = "all" ] && return 0
  echo ",$MODULES," | grep -qi ",$num," && return 0
  return 1
}

# --- Ask which modules BEFORE installing nodes ---
if [ -z "$MODULES" ]; then
  echo "================================================================"
  echo " Which modules do you want to install?"
  echo "================================================================"
  echo ""
  echo "  Available modules:"
  echo "   01       LLM Prompt Enhancer      (Ollama/Gemma3 — no download needed)"
  echo "   02       Image Deconstruction     (~8 GB)"
  echo "   03       Targeted Inpainting      (~8 GB)"
  echo "   04       Image to Gaussian Splat  (~1 GB)"
  echo "   05       Novel View Synthesis (~8 GB)"
  echo "   06       Image to Equirectangular (~12 GB)"
  echo "   07       Panorama to HDRI         (~24 GB)"
  echo "   08       Image to 3D    (~20 GB)"
  echo "   09       Image Cut Out Time to Move         (~100 GB)"
  echo "   10       Video to Video       (~130 GB)"
  echo "   bonus-a  Texture Extraction       (~8 GB)"
  echo "   bonus-b  Texture to PBR           (~12 GB)"
  echo ""
  echo "  Enter module numbers (e.g. 02,03,08), \"all\", or press Enter to skip:"
  echo ""
  read -p "  Modules: " MODULES || true
fi

echo ""
echo "Installing custom nodes into: $NODES_DIR"
mkdir -p "$NODES_DIR"
echo ""

# --- Core (always installed) ---
install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager"

# --- Modules 01 + 02: Qwen utilities ---
if module_selected "01" || module_selected "02"; then
  install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes"
  $PIP install -q librosa
  install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"
fi

# --- Module 01: LLM Prompt Enhancer ---
if module_selected "01"; then
  install_node "comfyui-ollama" "https://github.com/stavsap/comfyui-ollama"
fi

# --- Modules 02-07, Bonus A+B: TextureAlchemy ---
if module_selected "02" || module_selected "03" || module_selected "04" || \
   module_selected "05" || module_selected "06" || module_selected "07" || \
   module_selected "bonus-a" || module_selected "bonus-b"; then
  install_node "ComfyUI-TextureAlchemy" "https://github.com/amtarr/ComfyUI-TextureAlchemy" "Sandbox"
fi

# --- Module 03: Targeted Inpainting ---
if module_selected "03"; then
  install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
fi

# --- Modules 04 + 05: Gaussian Splat ---
if module_selected "04" || module_selected "05"; then
  install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp"
  install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack"
fi

# --- Module 06: Image to Equirectangular ---
if module_selected "06"; then
  install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"
  install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
  install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
fi

# --- Module 07: Panorama to HDRI ---
if module_selected "07"; then
  install_node "Luminance-Stack-Processor" "https://github.com/sumitchatterjee13/Luminance-Stack-Processor"
  install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold"
  echo "Patching ComfyUI-Marigold for numpy 2.0 compatibility..."
  sed -i 's/\.tostring()/.tobytes()/g' "$NODES_DIR/ComfyUI-Marigold/nodes.py"
fi

# --- Module 08: Trellis2 3D ---
if module_selected "08"; then
  install_node "ComfyUI-Trellis2" "https://github.com/visualbruno/ComfyUI-Trellis2"
  # Patch image_feature_extractor.py for transformers compatibility.
  # DINOv3ViTModel nesting changed across versions (.layer vs .model.layer).
  # Use getattr fallback so the code works regardless of transformers version.
  echo "          Patching Trellis2 for transformers compatibility..."
  FE_PY="$NODES_DIR/ComfyUI-Trellis2/trellis2/modules/image_feature_extractor.py"
  if [ -f "$FE_PY" ]; then
    sed -i "s/self\.model\.model\.layer/getattr(self.model,'model',self.model).layer/g" "$FE_PY"
    sed -i "s/self\.model\.layer/getattr(self.model,'model',self.model).layer/g" "$FE_PY"
  fi
fi

# --- Module 09: Image Cut Out Time to Move ---
if module_selected "09"; then
  install_node "comfy_nv_video_prep" "https://github.com/NVIDIA/comfy_nv_video_prep"
  install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
  install_node "ComfyUI_essentials" "https://github.com/cubiq/ComfyUI_essentials"
  install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
  install_node "comfyui-sam2" "https://github.com/neverbiasu/ComfyUI-SAM2"
  install_node "ComfyUI-SAM3" "https://github.com/PozzettiAndrea/ComfyUI-SAM3"
  install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
  install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
  install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"
  install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
  install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
  # triton must match PyTorch for torch.compile/inductor to work.
  # WanVideoWrapper uses torch.compile — triton 3.3+ removes triton_key which
  # torch 2.8.0 requires. Pin to 3.2.0 which is compatible with torch 2.8.x.
  echo "          Pinning triton to 3.2.0 for torch.compile compatibility..."
  "$PYTHON" -m pip install -q triton==3.2.0
fi

# --- Module 10: Video to Video ---
if module_selected "10"; then
  install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
  install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus"
  install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
  install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
  install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
  install_node "comfyui-post-processing-nodes" "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
  install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere"
  install_node "radiance" "https://github.com/fxtdstudios/radiance"
  install_node "comfyui-rtx-simple" "https://github.com/BetaDoggo/comfyui-rtx-simple"
  install_node "ComfyUI-Impact-Pack" "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
fi

# --- Bonus A: Texture Extraction ---
if module_selected "bonus-a"; then
  install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"
  install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
  install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
fi

# --- Bonus B: Texture to PBR ---
if module_selected "bonus-b"; then
  install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"
  install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus"
  install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold"
  echo "Patching ComfyUI-Marigold for numpy 2.0 compatibility..."
  sed -i 's/\.tostring()/.tobytes()/g' "$NODES_DIR/ComfyUI-Marigold/nodes.py"
fi


# --- Install template browser extension ---
# Creates a lightweight custom node whose example_workflows/ folder makes all
# workflows appear in ComfyUI's template browser under Extensions.
echo ""
echo "Installing template browser extension..."
TEMPLATE_NODE="NVIDIA-GenAI-Creator-Toolkit"
TEMPLATE_NODE_DIR="$NODES_DIR/$TEMPLATE_NODE"
mkdir -p "$TEMPLATE_NODE_DIR/example_workflows"
cp "$(dirname "$0")/custom_node/__init__.py" "$TEMPLATE_NODE_DIR/__init__.py"
for workflow_dir in "$(dirname "$0")/workflows"/*/; do
  module_name="$(basename "$workflow_dir")"
  if [ -f "${workflow_dir}${module_name}.json" ]; then
    cp "${workflow_dir}${module_name}.json" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.json"
    if [ -f "${workflow_dir}images/preview.png" ]; then
      cp "${workflow_dir}images/preview.png" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.jpg"
    elif [ -f "${workflow_dir}images/preview.gif" ]; then
      cp "${workflow_dir}images/preview.gif" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.jpg"
    fi
  fi
done
echo "  Workflows available in template browser: Extensions > $TEMPLATE_NODE"

# --- Offer to install Ollama if module 01 or all selected ---
NEEDS_OLLAMA=0
if module_selected "01"; then NEEDS_OLLAMA=1; fi

if [ "$NEEDS_OLLAMA" = "1" ]; then
  if ! command -v ollama > /dev/null 2>&1; then
    echo ""
    echo "================================================================"
    echo " Module 01 requires Ollama (not detected on this machine)"
    echo "================================================================"
    echo ""
    read -r -n 1 -p "  Install Ollama now? (Y/N): " INSTALL_OLLAMA < /dev/tty; echo
    if [[ "${INSTALL_OLLAMA,,}" == "y" ]]; then
      echo ""
      echo "  Installing Ollama..."
      curl -fsSL https://ollama.com/install.sh | sh
      echo ""
      read -r -n 1 -p "  Pull gemma3 model now? (~5 GB) (Y/N): " PULL_GEMMA < /dev/tty; echo
      if [[ "${PULL_GEMMA,,}" == "y" ]]; then
        echo ""
        ollama pull gemma3
      fi
    fi
  else
    echo ""
    echo "  Ollama already installed."
    if ! ollama list 2>/dev/null | grep -qi "gemma3"; then
      read -r -n 1 -p "  Pull gemma3 model now? (~5 GB) (Y/N): " PULL_GEMMA < /dev/tty; echo
      if [[ "${PULL_GEMMA,,}" == "y" ]]; then
        echo ""
        ollama pull gemma3
      fi
    else
      echo "  gemma3 already pulled."
    fi
  fi
fi

# --- Download models ---
if [ -n "$MODULES" ]; then
  echo ""
  echo "================================================================"
  echo " Downloading models for modules: $MODULES"
  echo "================================================================"
  echo ""
  echo "  TIP: Log in to HuggingFace for faster downloads and access to"
  echo "  gated models (required for Module 07 Flux):"
  echo "    huggingface-cli login"
  echo ""
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  $PYTHON "$SCRIPT_DIR/download_models.py" --comfyui "$COMFYUI_DIR" --modules "$MODULES"
fi

echo ""
echo "================================================================"
echo " Installation complete"
echo "================================================================"
echo ""
echo "  Workflows available in template browser: Browse Templates > Extensions > NVIDIA-GenAI-Creator-Toolkit"
echo ""
echo "  To install a different module later, run:"
echo "    bash install.sh $COMFYUI_DIR --modules 03"
echo "  (already-installed nodes are skipped automatically)"
echo ""

# --- Offer to launch ComfyUI ---
read -r -n 1 -p "  Launch ComfyUI now? (Y/N): " LAUNCH < /dev/tty; echo
if [[ "${LAUNCH,,}" == "y" ]]; then
  if [ -f "$COMFYUI_DIR/venv/bin/activate" ]; then
    echo ""
    echo "  Launching ComfyUI (venv)..."
    cd "$COMFYUI_DIR" && source venv/bin/activate && python main.py
  else
    echo ""
    echo "  Could not detect launch method. Start ComfyUI manually:"
    echo "    source venv/bin/activate && python main.py"
  fi
else
  echo ""
  echo "  To launch ComfyUI later:"
  echo "    source venv/bin/activate && python main.py"
fi
