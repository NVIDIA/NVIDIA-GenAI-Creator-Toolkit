# Requirements

## Hardware

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| GPU | NVIDIA RTX 30 series (8GB VRAM) | RTX 40/50 series (16GB+ VRAM) |
| RAM | 16GB | 32GB+ |
| Storage | 50GB free | 200GB+ free (models accumulate) |
| Platform | Windows 11 x86_64, Linux x86_64 | Windows 11, Linux x86_64 |

**NVFP4 quantization** (Modules 01, 08, 09, 10): Requires RTX 50 series (Blackwell) GPU.

**RTX Spark / ARM64**: Modules 01–08 are compatible. Module 09 and 10 (Wan2.2) require x86_64. RTX Video Super Resolution requires an x86_64 wheel — ARM64 build is not yet available.

## Software

- Python 3.10 or 3.11
- [ComfyUI](https://github.com/comfyanonymous/ComfyUI) — latest stable
- [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager) — required for custom node installation

## Installation (ComfyUI + Manager)

```bash
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI
pip install -r requirements.txt

# Install ComfyUI Manager
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager
```

Then launch ComfyUI:

```bash
cd ..
python main.py
```

Open `http://127.0.0.1:8188` in your browser.

## Custom Nodes

Each workflow lists its required nodes in `nodes.md`. Install them through ComfyUI Manager:

1. Click **Manager** in the ComfyUI sidebar
2. Click **Install Missing Custom Nodes**
3. Restart ComfyUI after installation

## Models

Most models download automatically when you first run a workflow. For large models (Wan2.2, Trellis2), pre-download is recommended. See each module's `models.md` for direct download links and expected paths.

Models are stored in `ComfyUI/models/` by default.
