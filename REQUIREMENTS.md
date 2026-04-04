# Requirements

## Hardware

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| GPU | NVIDIA RTX 30 series (8GB VRAM) | RTX 40/50 series (16GB+ VRAM) |
| RAM | 16GB | 32GB+ |
| Storage | 50GB free | 200GB+ free (models accumulate) |
| Platform | Windows 11 x86_64, Linux x86_64 | Windows 11, Linux x86_64 |

**NVFP4 quantization** (Modules 01, 08, 09, 10): Requires RTX 50 series (Blackwell) GPU.

**RTX Spark / ARM64**: Modules 01–08 are compatible. Module 09 and 10 (Wan2.2) require x86_64.

---

## Software

| Tool | Notes |
|------|-------|
| [Git](https://git-scm.com/downloads) | Required — Windows users: install Git for Windows |
| Python 3.10 or 3.11 | Required |
| [ComfyUI](https://github.com/comfyanonymous/ComfyUI) | Latest stable |
| [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager) | Required for custom node installation |
| `huggingface_hub` | Required for pre-downloading large models (Wan2.2, Trellis2) |

---

## Installation (ComfyUI + Manager)

### Linux

```bash
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI

# Create and activate a virtual environment (required on Linux)
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# Install ComfyUI Manager
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager
cd ..

# Install huggingface-cli (needed for large model downloads)
pip install huggingface_hub
```

**System packages (Ubuntu/Debian):**

```bash
sudo apt install git git-lfs ffmpeg libgl1 libglib2.0-0
```

> `ffmpeg` is required by ComfyUI-VideoHelperSuite for video output. On Windows, it is bundled automatically.

Launch ComfyUI:

```bash
source venv/bin/activate   # activate venv if not already active
python main.py
```

### Windows

The recommended path on Windows is the [ComfyUI portable release](https://github.com/comfyanonymous/ComfyUI/releases), which includes its own Python and pip. If using the portable release, run install.bat from its root directory.

If using a manual install with your own Python:

```bat
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager
cd ..

pip install huggingface_hub
```

Launch ComfyUI:

```bat
venv\Scripts\activate
python main.py
```

Open `http://127.0.0.1:8188` in your browser.

---

## Custom Nodes

Each workflow lists its required nodes in `nodes.md`. The fastest path is running `install.sh` / `install.bat` from this repo, which installs all node packs at once.

To install individually via ComfyUI Manager:

1. Click **Manager** in the ComfyUI sidebar
2. Click **Install Missing Custom Nodes**
3. Restart ComfyUI after installation

> **Important:** `ComfyUI-TextureAlchemy` must be installed from the `Sandbox` branch — the default branch does not include the required nodes. The install scripts handle this automatically. If installing manually, use:
> `git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy`

---

## Models

Most models must be downloaded manually before running a workflow. See each module's `models.md` for exact filenames, sizes, download URLs, and which subfolder of `ComfyUI/models/` to place each file in.

For large models (Wan2.2 ~28 GB, Trellis2 ~20 GB), use `huggingface-cli` to pre-download:

```bash
huggingface-cli download <repo-id> --local-dir ComfyUI/models/<destination>
```

If `huggingface-cli` is not found, install it first: `pip install huggingface_hub`
