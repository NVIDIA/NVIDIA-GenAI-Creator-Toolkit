# Requirements

## Hardware

| Requirement | Minimum | Suggested | Best Performance |
|-------------|---------|-----------|-----------------|
| GPU | RTX 4080 (16 GB VRAM) | RTX 4090 (24 GB VRAM) | RTX 5090 (32 GB) / RTX PRO 6000 (96 GB) |
| System RAM | 32 GB | 48 GB | 64 GB / 192 GB |
| Storage | 50 GB NVMe SSD | 200 GB NVMe SSD | 500 GB+ NVMe SSD |
| Platform | Windows 11 x86_64, Linux x86_64 | Windows 11 x86_64 | Windows 11 x86_64 |

**NVFP4 quantization** is an optional performance optimization available on RTX 50 series (Blackwell) GPUs. All modules run without it on RTX 30/40 series.

**RTX Spark / ARM64**: Modules 01–08 are compatible. Module 09 and 10 (Wan2.2) require x86_64.

### Per-Module Requirements

Requirements below assume single-image or short-video generation at moderate resolution (1024×1024 image or 480p video). Higher resolutions and longer videos require more VRAM.

| Module | Min GPU | Suggested GPU | Best GPU | SSD Space | System RAM |
|--------|---------|---------------|----------|-----------|------------|
| 01 LLM Prompt Enhancer | RTX 3060 (12 GB) | RTX 4080 (16 GB) | RTX 5090 (32 GB) | ~5 GB | 32 GB |
| 02 Image Deconstruction | RTX 4080 (16 GB) ¹ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~12 GB | 32 GB |
| 03 Targeted Inpainting | RTX 4080 (16 GB) ¹ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~8 GB ² | 32 GB |
| 04 Image → Gaussian Splat | RTX 3060 (12 GB) | RTX 4080 (16 GB) | RTX 5090 (32 GB) | ~1 GB | 32 GB |
| 05 Gaussian Splat SceneFill | RTX 4080 (16 GB) ¹ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~8 GB ² | 32 GB |
| 06 Image → Equirectangular | RTX 4080 (16 GB) ¹ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~12 GB | 32 GB |
| 07 Panorama → HDRI | RTX 4080 (16 GB) | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~25 GB | 32 GB |
| 08 Trellis2 3D Asset Gen | RTX 3090 (24 GB) | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~20 GB | 48 GB |
| 09 Cutout Animation → Video | RTX 4080 (16 GB) ³ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~30 GB | 32 GB ⁴ |
| 10 Playblast → Video | RTX 4090 (24 GB) ⁵ | RTX 5090 (32 GB) | RTX PRO 6000 (96 GB) | ~30 GB | 48 GB |
| Bonus A Texture Extraction | RTX 4080 (16 GB) ¹ | RTX 4090 (24 GB) | RTX 5090 (32 GB) | ~8 GB ² | 32 GB |
| Bonus B Texture → PBR | RTX 3060 (12 GB) | RTX 4080 (16 GB) | RTX 5090 (32 GB) | ~12 GB | 32 GB |

¹ FP8 quantized checkpoint required to fit in 16 GB VRAM; BF16 checkpoint needs 24 GB+. Generation will be slower than on 24 GB.

² Shares the Qwen model stack with other Qwen-based modules (02, 03, 05, 06, Bonus A). If the Qwen stack is already downloaded for a prior module, no additional storage is needed for the models — only the module-specific LoRA (~0.5 GB).

³ Requires FP8 quantization and KJNodes block-swap (CPU offload) enabled in the workflow. Generation will be slow. 24 GB recommended for practical use.

⁴ 32 GB RAM is the 2× VRAM baseline for a 16 GB GPU. If using block-swap at 16 GB VRAM, 48 GB is recommended — block-swap offloads model layers to system RAM during generation.

⁵ Maximum CPU offloading required in ComfyUI-WanVideoWrapper settings. 48 GB RAM is the 2× VRAM baseline for a 24 GB GPU and provides sufficient offloading headroom. Module 10 was developed and tested on A100-class hardware; RTX PRO 6000 is the recommended workstation option for comfortable generation at full resolution.

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
# If this fails with "ensurepip not available", install the venv package first:
#   sudo apt install python3-venv   (or: sudo apt install python3.12-venv)
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
sudo apt install git git-lfs ffmpeg libgl1 libglib2.0-0 python3-venv
```

> `ffmpeg` is required by ComfyUI-VideoHelperSuite for video output. On Windows, it is bundled automatically.

Launch ComfyUI:

```bash
source venv/bin/activate   # activate venv if not already active
python main.py
```

### Windows

The recommended path on Windows is the [ComfyUI desktop app](https://www.comfy.org/download), which handles Python, CUDA, and updates automatically. After installing, run `install.bat` pointing at the folder inside the app that contains `main.py` — it is nested under `resources\ComfyUI` within the app's install location. To find it, run `where /r C:\ main.py` in Command Prompt.

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

> **Windows users: run `install.bat` from Command Prompt (`cmd.exe`), not Git Bash or PowerShell.**
> Git Bash does not execute `.bat` files through cmd.exe, so the script will appear to do nothing.
>
> - **Command Prompt:** `install.bat C:\path\to\ComfyUI`
> - **PowerShell:** `cmd /c install.bat C:\path\to\ComfyUI`
> - **Git Bash:** Open a separate Command Prompt window and run from there

To install individually via ComfyUI Manager:

1. Click **Manager** in the ComfyUI sidebar
2. Click **Install Missing Custom Nodes**
3. Restart ComfyUI after installation

> **Important:** `ComfyUI-TextureAlchemy` must be installed from the `Sandbox` branch — the default branch does not include the required nodes. The install scripts handle this automatically. If installing manually, use:
> `git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy`

---

## Models

Most models must be downloaded manually before running a workflow. See each module's `models.md` for exact filenames, sizes, download URLs, and which subfolder of `ComfyUI/models/` to place each file in.

For large models (Wan2.2 ~28 GB, Trellis2 ~20 GB), use `huggingface-cli` to pre-download.

**Run download commands from the parent directory of your ComfyUI install** — i.e., the folder that *contains* the `ComfyUI/` directory:

```bash
# Linux example — run from the folder containing ComfyUI/
huggingface-cli download Wan-AI/Wan2.2-Fun-14B-VACE --local-dir ComfyUI/models/video/wan

# Or use an absolute path from anywhere
huggingface-cli download Wan-AI/Wan2.2-Fun-14B-VACE --local-dir /path/to/ComfyUI/models/video/wan
```

If `huggingface-cli` is not found, install it first (with your venv active): `pip install huggingface_hub`

**Model subdirectories:** Some destination paths (e.g. `ComfyUI/models/diffusion_models/qwen/`, `ComfyUI/models/loras/qwen/`, `ComfyUI/models/sam2/`) do not exist on a fresh ComfyUI install. Create them before downloading:

```bash
mkdir -p ComfyUI/models/diffusion_models/qwen
mkdir -p ComfyUI/models/text_encoders/qwen
mkdir -p ComfyUI/models/vae/qwen
mkdir -p ComfyUI/models/loras/qwen
mkdir -p ComfyUI/models/diffusion_models/lotus
mkdir -p ComfyUI/models/sam2
mkdir -p ComfyUI/models/video/wan
```

`huggingface-cli` creates the target directory automatically. Manual downloads (browser/wget) require the directories to exist first.

You can also use `download_models.py` (included in this repo) to download models for one or more modules at once:

```bash
# Download models for specific modules
python download_models.py --comfyui C:\path\to\ComfyUI --modules 01,02,03

# Download everything
python download_models.py --comfyui C:\path\to\ComfyUI --modules all
```

---

## Recommended Starting Point

The full repo is ~160–180 GB across all modules. If you're exploring for the first time, start with a small subset that doesn't require large model downloads:

| Module | Storage | Why start here |
|--------|---------|----------------|
| [01 LLM Prompt Enhancer](workflows/01-llm-prompt-enhancer/) | ~4 GB (Gemma 3 via Ollama) | Fast setup, no HuggingFace download |
| [02 Image Deconstruction](workflows/02-image-deconstruction/) | ~12 GB | Demonstrates Qwen stack |
| [03 Targeted Inpainting](workflows/03-targeted-inpainting/) | Shared with 02 | No additional download |

Modules 02–06 and Bonus A all share the same Qwen model stack (~30 GB total). Download once, run five modules.

Modules 09–10 (Wan2.2) and 08 (Trellis2) have the largest individual downloads (28 GB and 20 GB respectively) — save those for when you're ready to commit.

---

## Troubleshooting

**`install.bat` does nothing / no output**
Running from Git Bash. Open a Command Prompt (`cmd.exe`) and run from there:
```
install.bat C:\path\to\ComfyUI
```

**`git` is not recognized**
Git is not installed or not in PATH. Install [Git for Windows](https://git-scm.com/downloads) and restart your terminal.

**`huggingface-cli` is not found**
Install it with your venv active: `pip install huggingface_hub`
On ComfyUI Portable: `python_embeded\python.exe -m pip install huggingface_hub`

**ComfyUI shows "Failed to import" or missing node errors**
1. Restart ComfyUI after running `install.bat` / `install.sh`
2. If errors persist, open ComfyUI Manager → Install Missing Custom Nodes
3. For `ComfyUI-TextureAlchemy` specifically, ensure it was cloned from the `Sandbox` branch of [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) — the Manager installs the wrong branch by default

**VRAM out of memory (OOM) during generation**
- Close other GPU applications (browsers with hardware acceleration, games, other AI tools)
- For Wan2.2 modules (09–10): reduce sequence length — stay under 120 frames for 16 GB VRAM
- For Trellis2 (08): reduce output resolution

**Workflow loads but all nodes show as red/missing**
The workflow references node types that aren't installed. Run `install.bat` / `install.sh` and restart ComfyUI, then reload the workflow.

**Module 09: first workflow run produces no video**
Module 09 requires two workflows in sequence: run `videoprep.json` first to prepare inputs, then `workflow.json` for generation. See the Module 09 README for the full two-step process.

**Module 09: `ComfyUI-Impact-Pack` shows "IMPORT FAILED" in ComfyUI Manager**
Impact Pack requires `ultralytics` and `onnxruntime`, which can fail to install on ComfyUI Portable's embedded Python. Fix:
```
python_embeded\python.exe -m pip install ultralytics onnxruntime
```
Then restart ComfyUI. If `onnxruntime` conflicts with `onnxruntime-gpu`, install the GPU variant instead:
```
python_embeded\python.exe -m pip install ultralytics onnxruntime-gpu
```

**Modules 09–10: `TritonMissing` error during generation**
Triton is not available in ComfyUI Portable's embedded Python on Windows. The error looks like:
```
torch._inductor.exc.TritonMissing: Cannot find a working triton installation.
```
**Fix:** In the `WanVideoSampler` node, set **`torch_compile_args`** to disabled / off. The workflow runs correctly without torch compilation — generation speed is unaffected for most GPUs.
