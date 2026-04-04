#!/usr/bin/env bash
# install.sh — ComfyUI custom node installer for comfyui-generative-ai-workflows
# No UI. Run from the ComfyUI root directory:
#   bash /path/to/comfyui-generative-ai-workflows/install.sh
#
# Does NOT download models — see each module's models.md for that.

set -e

COMFYUI_DIR="${1:-$(pwd)}"
NODES_DIR="$COMFYUI_DIR/custom_nodes"

if [ ! -f "$COMFYUI_DIR/main.py" ]; then
  echo "ERROR: ComfyUI not found. Pass the path as an argument:"
  echo "  bash install.sh /path/to/ComfyUI"
  exit 1
fi

# Detect venv and use its pip, or fall back to system pip with a warning
if [ -n "$VIRTUAL_ENV" ]; then
  PIP="$VIRTUAL_ENV/bin/pip"
elif [ -f "$COMFYUI_DIR/venv/bin/pip" ]; then
  PIP="$COMFYUI_DIR/venv/bin/pip"
  echo "NOTE: Using venv pip at $PIP (activate the venv first for best results)"
else
  PIP="pip"
  echo "WARNING: No venv detected. If pip installs fail, activate your ComfyUI venv first:"
  echo "  source $COMFYUI_DIR/venv/bin/activate"
fi

echo "Installing custom nodes into: $NODES_DIR"
mkdir -p "$NODES_DIR"

install_node() {
  local name="$1"
  local repo="$2"
  local branch="${3:-}"
  local dir="$NODES_DIR/$name"

  if [ -d "$dir" ]; then
    echo "  [skip] $name already installed"
  else
    echo "  [install] $name"
    if [ -n "$branch" ]; then
      git clone --depth 1 --branch "$branch" "$repo" "$dir"
    else
      git clone --depth 1 "$repo" "$dir"
    fi
  fi

  if [ -f "$dir/requirements.txt" ]; then
    $PIP install -q -r "$dir/requirements.txt"
  fi
}

echo ""
echo "=== ComfyUI Manager ==="
install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager"

echo ""
echo "=== Modules 01 + 02 — Qwen utilities ==="
install_node "ComfyUI-WJNodes" "https://github.com/807502278/ComfyUI-WJNodes"
install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use"

echo ""
echo "=== Module 01 — LLM Prompt Enhancer ==="
install_node "comfyui-ollama" "https://github.com/stavsap/comfyui-ollama"

echo ""
echo "=== Modules 02–07, Bonus A+B — TextureAlchemy (Qwen/HDRI custom nodes) ==="
install_node "ComfyUI-TextureAlchemy" "https://github.com/amtarr/ComfyUI-TextureAlchemy" "Sandbox"

echo ""
echo "=== Modules 04 + 05 — Gaussian Splat ==="
install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp"
install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack"

echo ""
echo "=== Module 08 — Trellis2 3D ==="
install_node "ComfyUI-TRELLIS2" "https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2"

echo ""
echo "=== Module 09 — Cutout Animation (VideoPrep + TTM) ==="
install_node "comfy_nv_video_prep" "https://github.com/NVIDIA/comfy_nv_video_prep"
install_node "ComfyUI-Custom-Scripts" "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
install_node "ComfyUI_essentials" "https://github.com/cubiq/ComfyUI_essentials"
install_node "ComfyUI-Inpaint-CropAndStitch" "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
install_node "comfyui-sam2" "https://github.com/neverbiasu/ComfyUI-SAM2"
install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"

echo ""
echo "=== Module 10 — Playblast to Video (Wan VACE) ==="
install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
install_node "ComfyUI-KJNodes" "https://github.com/kijai/ComfyUI-KJNodes"
install_node "cg-use-everywhere" "https://github.com/chrisgoringe/cg-use-everywhere"
install_node "radiance" "https://github.com/fxtdstudios/radiance"

echo ""
echo "=== Modules 10 + Bonus B — Lotus depth estimation ==="
install_node "ComfyUI-Lotus" "https://github.com/kijai/ComfyUI-Lotus"

echo ""
echo "=== Bonus B — Texture to PBR ==="
install_node "ComfyUI-Marigold" "https://github.com/kijai/ComfyUI-Marigold"

echo ""
echo "=== Done ==="
echo ""
echo "Next steps:"
echo "  1. Install Ollama for Module 01: https://ollama.com/download"
echo "     Then: ollama pull gemma3"
echo "  2. Download models — see each workflow's models.md"
echo "     Large models (Wan2.2, Trellis2) should be pre-downloaded before running"
echo "  3. Launch ComfyUI: source venv/bin/activate && python main.py"
echo "  4. Drag a workflow.json into the ComfyUI canvas"
