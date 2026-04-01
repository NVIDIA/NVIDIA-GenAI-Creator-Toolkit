#!/usr/bin/env bash
# install.sh — ComfyUI custom node installer for comfyui-generative-ai-workflows
# No UI. Run from the ComfyUI root directory:
#   bash /path/to/comfyui-generative-ai-workflows/install.sh
#
# What this does:
#   1. Installs ComfyUI-Manager (if not already present)
#   2. Clones all required custom node packs
#   3. Installs each pack's Python dependencies
#   4. Prompts you to install Ollama (required for Module 01)
#
# Does NOT download models — see each module's models.md for that.

set -e

COMFYUI_DIR="${1:-$(pwd)}"
NODES_DIR="$COMFYUI_DIR/custom_nodes"

if [ ! -f "$COMFYUI_DIR/main.py" ]; then
  echo "ERROR: Run this from the ComfyUI root directory, or pass it as an argument:"
  echo "  bash install.sh /path/to/ComfyUI"
  exit 1
fi

echo "Installing custom nodes into: $NODES_DIR"
mkdir -p "$NODES_DIR"

install_node() {
  local name="$1"
  local repo="$2"
  local dir="$NODES_DIR/$name"

  if [ -d "$dir" ]; then
    echo "  [skip] $name already installed"
  else
    echo "  [install] $name"
    git clone --depth 1 "$repo" "$dir"
  fi

  if [ -f "$dir/requirements.txt" ]; then
    pip install -q -r "$dir/requirements.txt"
  fi
}

echo ""
echo "=== ComfyUI Manager ==="
install_node "ComfyUI-Manager" "https://github.com/ltdrdata/ComfyUI-Manager"

echo ""
echo "=== Module 01 — LLM Prompt Enhancer ==="
install_node "ComfyUI-Ollama" "https://github.com/stavsap/ComfyUI-Ollama"

echo ""
echo "=== Modules 04 + 05 — Gaussian Splat ==="
install_node "ComfyUI-Sharp" "https://github.com/PozzettiAndrea/ComfyUI-Sharp"
install_node "ComfyUI-GeometryPack" "https://github.com/PozzettiAndrea/ComfyUI-GeometryPack"

echo ""
echo "=== Module 08 — Trellis2 ==="
install_node "ComfyUI-TRELLIS2" "https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2"

echo ""
echo "=== Modules 09 + 10 — Wan Video ==="
install_node "ComfyUI-WanVideoWrapper" "https://github.com/kijai/ComfyUI-WanVideoWrapper"
install_node "ComfyUI-VideoHelperSuite" "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
install_node "comfyui_controlnet_aux" "https://github.com/Fannovel16/comfyui_controlnet_aux"

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
echo "  3. Launch ComfyUI: python main.py"
echo "  4. Drag a workflow.json into the ComfyUI canvas"
