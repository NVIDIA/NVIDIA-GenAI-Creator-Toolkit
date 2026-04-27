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
#
# Remove model files for a module (frees disk space; shared models are kept):
#   bash install.sh /path/to/ComfyUI --clean --modules 04

set -euo pipefail

# Parse arguments
COMFYUI_DIR=""
MODULES=""
CLEAN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --modules) MODULES="$2"; shift 2 ;;
    --clean)   CLEAN=1; shift ;;
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

if [ "$CLEAN" != "1" ] && [ ! -f "$COMFYUI_DIR/main.py" ]; then
  echo "ERROR: main.py not found at: $COMFYUI_DIR"
  echo ""
  echo "  Pass the ComfyUI root directory (the folder containing main.py):"
  echo "    bash install.sh /path/to/ComfyUI"
  exit 1
fi

echo "ComfyUI path: $COMFYUI_DIR"
echo ""

# --- Early exit if every selected module is Linux-incompatible (currently only 08) ---
if [ -n "$MODULES" ] && [ "${MODULES,,}" != "all" ] && [ "$CLEAN" != "1" ]; then
  _all_incompatible=1
  IFS=',' read -ra _compat_tokens <<< "$MODULES"
  for _tok in "${_compat_tokens[@]}"; do
    _tok="${_tok// /}"
    if [ "$_tok" != "08" ]; then
      _all_incompatible=0
      break
    fi
  done
  if [ "$_all_incompatible" = "1" ]; then
    echo "  Module 08 (Image to 3D / Trellis2) is not available on Linux."
    echo ""
    echo "  Trellis2 requires pre-built CUDA extensions (cumesh, nvdiffrast)"
    echo "  that are Windows-only. Nothing was installed."
    echo ""
    exit 0
  fi
fi

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
if [ "$CLEAN" != "1" ] && [ -z "$MODULES" ]; then
  echo "================================================================"
  echo " Which modules do you want to install?"
  echo "================================================================"
  echo ""
  echo "  Available modules:"
  echo "   01       LLM Prompt Enhancer      (~65 GB, Gemma3 via Ollama)"
  echo "   02       Image Deconstruction     (~51 GB)"
  echo "   03       Targeted Inpainting      (~52 GB)"
  echo "   04       Image to Gaussian Splat  (~3 GB)"
  echo "   05       Novel View Synthesis     (~60 GB)"
  echo "   06       Image to Equirectangular (~61 GB)"
  echo "   07       Panorama to HDRI         (~23 GB)"
  echo "   08       Image to 3D              (~20 GB)"
  echo "   09       Image Cut Out Time to Move (~77 GB)"
  echo "   10       Video to Video           (~143 GB)"
  echo "   bonus-a  Texture Extraction       (~60 GB)"
  echo "   bonus-b  Texture to PBR           (~10 GB)"
  echo ""
  echo "  Enter module numbers (e.g. 02,03,bonus-a), \"all\", or press Enter to skip:"
  echo ""
  read -p "  Modules: " MODULES || true
fi

# --- Validate module names ---
if [ -n "$MODULES" ] && [ "${MODULES,,}" != "all" ]; then
  _valid=" 01 02 03 04 05 06 07 08 09 10 bonus-a bonus-b "
  IFS=',' read -ra _tokens <<< "$MODULES"
  for _tok in "${_tokens[@]}"; do
    _tok="${_tok// /}"
    if [[ "$_valid" != *" $_tok "* ]]; then
      echo ""
      echo "[ERROR] Unknown module '$_tok'. Valid: 01-10, bonus-a, bonus-b"
      echo ""
      exit 1
    fi
  done
fi

echo ""
echo "Installing custom nodes into: $NODES_DIR"
mkdir -p "$NODES_DIR"
echo ""

# --- Clean mode: remove model files and exit, skip node install ---
if [ "$CLEAN" = "1" ]; then
  if [ -z "$MODULES" ]; then
    echo ""
    echo "[ERROR] --clean requires --modules. Specify which modules to clean."
    echo "Example: bash install.sh $COMFYUI_DIR --clean --modules 04"
    echo ""
    exit 1
  fi
  echo ""
  echo "================================================================"
  echo " Removing model files for modules: $MODULES"
  echo "================================================================"
  echo ""
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  $PYTHON "$SCRIPT_DIR/download_models.py" --comfyui "$COMFYUI_DIR" --modules "$MODULES" --clean
  exit 0
fi

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
  echo ""
  echo "  [Module 08] Trellis2 3D is Windows only."
  echo "              Trellis2 CUDA extensions (cumesh, nvdiffrast) are pre-built wheels"
  echo "              tied to specific PyTorch versions. ABI incompatibilities with current"
  echo "              PyTorch releases on Linux prevent the nodes from loading."
  echo "              Skipping Module 08 on Linux."
  echo ""
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


# --- Copy workflow JSONs into ComfyUI Workflows tab ---
WORKFLOWS_DEST="$COMFYUI_DIR/user/default/workflows/NVIDIA-GenAI-Creator-Toolkit"
mkdir -p "$WORKFLOWS_DEST"
for workflow_dir in "$(dirname "$0")/workflows"/*/; do
  module_name="$(basename "$workflow_dir")"
  module_num=$(echo "$module_name" | sed 's/^\(bonus-[ab]\|[0-9][0-9]\)-.*/\1/')
  [ "$module_num" = "08" ] && continue  # Module 08 is Windows only
  if [ -z "$MODULES" ] || module_selected "$module_num"; then
    if [ -f "${workflow_dir}${module_name}.json" ]; then
      mkdir -p "$WORKFLOWS_DEST/$module_name"
      cp "${workflow_dir}${module_name}.json" "$WORKFLOWS_DEST/$module_name/$module_name.json"
      if [ -f "${workflow_dir}${module_name}-videoprep.json" ]; then
        cp "${workflow_dir}${module_name}-videoprep.json" "$WORKFLOWS_DEST/$module_name/${module_name}-videoprep.json"
      fi
    fi
  fi
done
echo "Workflows copied to: $WORKFLOWS_DEST"

# --- Copy sample inputs into ComfyUI ---
INPUTS_DEST="$COMFYUI_DIR/input"
mkdir -p "$INPUTS_DEST"
for workflow_dir in "$(dirname "$0")/workflows"/*/; do
  module_name="$(basename "$workflow_dir")"
  module_num=$(echo "$module_name" | sed 's/^\(bonus-[ab]\|[0-9][0-9]\)-.*/\1/')
  [ "$module_num" = "08" ] && continue  # Module 08 is Windows only
  if [ -z "$MODULES" ] || module_selected "$module_num"; then
    if [ -d "${workflow_dir}input" ]; then
      cp "${workflow_dir}input/"* "$INPUTS_DEST/" 2>/dev/null || true
    fi
  fi
done
echo "Sample inputs copied to: $INPUTS_DEST"

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
  module_num=$(echo "$module_name" | sed 's/^\(bonus-[ab]\|[0-9][0-9]\)-.*/\1/')
  [ "$module_num" = "08" ] && continue  # Module 08 is Windows only
  if [ -z "$MODULES" ] || module_selected "$module_num"; then
    if [ -f "${workflow_dir}${module_name}.json" ]; then
      cp "${workflow_dir}${module_name}.json" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.json"
      if [ -f "${workflow_dir}${module_name}-videoprep.json" ]; then
        cp "${workflow_dir}${module_name}-videoprep.json" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}-videoprep.json"
        if [ -f "${workflow_dir}images/preview-videoprep.jpg" ]; then
          cp "${workflow_dir}images/preview-videoprep.jpg" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}-videoprep.jpg"
        fi
      fi
      if [ -f "${workflow_dir}images/preview.png" ]; then
        cp "${workflow_dir}images/preview.png" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.jpg"
      elif [ -f "${workflow_dir}images/preview.gif" ]; then
        cp "${workflow_dir}images/preview.gif" "$TEMPLATE_NODE_DIR/example_workflows/${module_name}.jpg"
      fi
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
    read -r -n 1 -p "  Install Ollama now? [Y/N]:" INSTALL_OLLAMA < /dev/tty; echo
    if [[ "${INSTALL_OLLAMA,,}" == "y" ]]; then
      echo ""
      echo "  Installing Ollama..."
      curl -fsSL https://ollama.com/install.sh | sh
      echo ""
      read -r -n 1 -p "  Pull gemma3 model now? (~5 GB) [Y/N]:" PULL_GEMMA < /dev/tty; echo
      if [[ "${PULL_GEMMA,,}" == "y" ]]; then
        echo ""
        ollama pull gemma3
      fi
    fi
    # Re-check in case Ollama was present but undetected at script start (e.g. not yet in PATH)
    if command -v ollama > /dev/null 2>&1; then
      echo ""
      echo "  Ollama detected."
      if ! ollama list 2>/dev/null | grep -qi "gemma3"; then
        read -r -n 1 -p "  Pull gemma3 model now? (~5 GB) [Y/N]:" PULL_GEMMA < /dev/tty; echo
        if [[ "${PULL_GEMMA,,}" == "y" ]]; then
          echo ""
          ollama pull gemma3
        fi
      else
        echo "  gemma3 already pulled."
      fi
    fi
  else
    echo ""
    echo "  Ollama already installed."
    if ! ollama list 2>/dev/null | grep -qi "gemma3"; then
      read -r -n 1 -p "  Pull gemma3 model now? (~5 GB) [Y/N]:" PULL_GEMMA < /dev/tty; echo
      if [[ "${PULL_GEMMA,,}" == "y" ]]; then
        echo ""
        ollama pull gemma3
      fi
    else
      echo "  gemma3 already pulled."
    fi
  fi
fi

# --- HuggingFace login ---
if [ -n "$MODULES" ]; then
  echo ""
  echo "================================================================"
  echo " Step: HuggingFace Login"
  echo "================================================================"
  echo ""
  echo "  HuggingFace login is required for:"
  echo "    - Faster, rate-limit-free downloads"
  echo "    - Gated models (Module 07 Flux.1-dev)"
  echo ""
  HF_LOGGED_IN=0
  if $PYTHON -c "from huggingface_hub import get_token; exit(0 if get_token() else 1)" 2>/dev/null; then
    HF_LOGGED_IN=1
    echo "  Already logged in to HuggingFace."
  fi
  if [ "$HF_LOGGED_IN" = "0" ]; then
    echo "  Not currently logged in."
    read -r -n 1 -p "  Log in to HuggingFace now? [Y/N]:" DO_HF_LOGIN < /dev/tty; echo
    if [[ "${DO_HF_LOGIN,,}" == "y" ]]; then
      echo ""
      echo "  Running: huggingface-cli login"
      echo "  (You will be prompted to enter or paste your HuggingFace token.)"
      echo "  Get a token at: https://huggingface.co/settings/tokens"
      echo ""
      HF_CLI_BIN="$(dirname "$PYTHON")/huggingface-cli"
      if [ -x "$HF_CLI_BIN" ]; then
        "$HF_CLI_BIN" login < /dev/tty || true
      else
        echo "  huggingface-cli not found. Run manually after install: huggingface-cli login"
      fi
    else
      echo ""
      echo "  Skipping login. Gated model downloads (Module 07) will fail."
      echo "  To log in later: huggingface-cli login"
    fi
  fi
  echo ""
fi

# --- Download models ---
if [ -n "$MODULES" ]; then
  # Module 08 (Trellis2) is Windows only — exclude from model downloads on Linux
  DOWNLOAD_MODULES="$MODULES"
  if [ "${MODULES,,}" = "all" ]; then
    DOWNLOAD_MODULES="01,02,03,04,05,06,07,09,10,bonus-a,bonus-b"
  else
    DOWNLOAD_MODULES=$(echo "$MODULES" | tr ',' '\n' | grep -v '^08$' | tr '\n' ',' | sed 's/,$//')
  fi

  if [ -z "$DOWNLOAD_MODULES" ]; then
    echo "  No models to download (Module 08 is Windows only, skipping on Linux)."
  else
    echo ""
    echo "================================================================"
    echo " Downloading models for modules: $DOWNLOAD_MODULES"
    echo "================================================================"
    echo ""
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    $PYTHON "$SCRIPT_DIR/download_models.py" --comfyui "$COMFYUI_DIR" --modules "$DOWNLOAD_MODULES"
    DOWNLOAD_EXIT=$?
    if [ "$DOWNLOAD_EXIT" != "0" ]; then
      echo ""
      echo "================================================================"
      echo " [ERROR] One or more model downloads failed after 3 attempts."
      echo "================================================================"
      echo ""
      echo "  This is usually a temporary network or HuggingFace issue."
      echo "  Already-downloaded models will be skipped on retry."
      echo ""
      echo "  To retry, run:"
      echo "    bash install.sh $COMFYUI_DIR --modules $MODULES"
      echo ""
      echo "  Do NOT launch ComfyUI until all models are downloaded —"
      echo "  workflows will fail to run with missing models."
      echo ""
      exit 1
    fi
  fi
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

# --- Restart instructions ---
echo "  ----------------------------------------------------------------"
echo "  ComfyUI must be restarted to load the newly installed nodes."
echo ""
echo "  If ComfyUI is already running in a screen session:"
echo "    screen -r comfyui          # reattach"
echo "    Ctrl+C                     # stop ComfyUI"
echo "    python3 $COMFYUI_DIR/main.py --listen   # restart"
echo "    Ctrl+A, D                  # detach"
echo ""
echo "  If ComfyUI is not running yet:"
echo "    screen -S comfyui"
echo "    source $COMFYUI_DIR/venv/bin/activate"
echo "    python3 $COMFYUI_DIR/main.py --listen"
echo "    Ctrl+A, D                  # detach"
echo "  ----------------------------------------------------------------"
echo ""
