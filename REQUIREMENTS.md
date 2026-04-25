# Requirements

## Hardware

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| GPU — Windows | RTX 4080 (16 GB) | RTX 5090 (32 GB) |
| GPU — Linux | RTX 5090 (32 GB) | RTX PRO 6000 (96 GB) |
| System RAM | 32 GB | 48 GB |
| Storage | 50 GB NVMe SSD | 200 GB NVMe SSD |
| Platform | Windows 11 x86_64, Linux x86_64 | — |

**NVFP4 quantization** is an optional performance optimization available on RTX 50 series (Blackwell) GPUs. All modules run without it on RTX 40 series.

**Windows vs Linux VRAM:** On Windows, NVIDIA weight streaming offloads model layers to system RAM when VRAM is full — a 4090 (24 GB) handles most modules comfortably. On Linux, weight streaming is not available; the full model must fit in VRAM. An RTX 4090 will encounter OOM errors on modules that run fine on Windows with the same GPU. **RTX 5090 (32 GB) is the recommended minimum for Linux.** Use `--lowvram` or `--novram` ComfyUI launch flags as a workaround on 24 GB cards (generation will be slower).

**RTX Spark / ARM64**: Modules 01–07 and Bonus A/B are compatible. Module 08 (Trellis2) is Windows x86_64 only. Modules 09 and 10 (Wan2.2) require x86_64.

### Per-Module Requirements

Each module's page lists its exact VRAM, SSD space, RAM, generation time, models, custom nodes, and troubleshooting steps.

| Module | Details |
|--------|---------|
| 01 LLM Prompt Enhancer | [modules/01-llm-prompt-enhancer.md](modules/01-llm-prompt-enhancer.md) |
| 02 Image Deconstruction | [modules/02-image-deconstruction.md](modules/02-image-deconstruction.md) |
| 03 Targeted Inpainting | [modules/03-targeted-inpainting.md](modules/03-targeted-inpainting.md) |
| 04 Image to Gaussian Splat | [modules/04-image-to-gaussian-splat.md](modules/04-image-to-gaussian-splat.md) |
| 05 Novel View Synthesis | [modules/05-novel-view-synthesis.md](modules/05-novel-view-synthesis.md) |
| 06 Image to Equirectangular | [modules/06-image-to-equirectangular.md](modules/06-image-to-equirectangular.md) |
| 07 Panorama to HDRI | [modules/07-panorama-to-hdri.md](modules/07-panorama-to-hdri.md) |
| 08 Image to 3D | [modules/08-image-to-3d.md](modules/08-image-to-3d.md) |
| 09 Image Cut Out Time to Move | [modules/09-image-cut-out-time-to-move.md](modules/09-image-cut-out-time-to-move.md) |
| 10 Video to Video | [modules/10-video-to-video.md](modules/10-video-to-video.md) |
| Bonus A — Texture Extraction | [modules/bonus-a-texture-extraction.md](modules/bonus-a-texture-extraction.md) |
| Bonus B — Texture to PBR | [modules/bonus-b-texture-to-pbr.md](modules/bonus-b-texture-to-pbr.md) |

---

## Software

| Tool | Notes |
|------|-------|
| [Git](https://git-scm.com/downloads) | Required — Windows users: install Git for Windows |
| Python 3.10–3.12 | Required — Python 3.13 is not yet supported (Module 08 Trellis2 requires 3.11 or 3.12) |
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

> On Ubuntu 24.04 (Python 3.12), `python3-venv` may fail with "ensurepip not available". Install the version-specific package instead:
> ```bash
> sudo apt install python3.12-venv
> ```

> `ffmpeg` is required by ComfyUI-VideoHelperSuite for video output. On Windows, it is bundled automatically.

> **CUDA requirement:** ComfyUI requires CUDA 12.x. Ubuntu 24.04 ships with CUDA 12 via the NVIDIA driver package. Verify with `nvidia-smi` — if CUDA Version shows 12.x you're ready. If you installed the driver manually and see CUDA 13+, the installer will downgrade PyTorch to a CUDA 12-compatible build automatically.

Launch ComfyUI:

```bash
source venv/bin/activate   # activate venv if not already active
python3 main.py --listen
```

> **`--listen` is required on headless Linux machines** — without it, ComfyUI only accepts connections from localhost and the browser tunnel will fail.

**Accessing the UI from a remote Windows machine (SSH tunnel):**

In a separate PowerShell window on your Windows machine:
```powershell
& "C:\Program Files\Git\usr\bin\ssh.exe" -L 8188:localhost:8188 username@<linux-ip>
```
Then open `http://localhost:8188` in your browser. Keep the PowerShell window open — the tunnel stays active as long as the connection is alive.

**Keeping ComfyUI running after SSH disconnect:**

Use `screen` so ComfyUI survives disconnects:
```bash
screen -S comfyui
source ~/ComfyUI/venv/bin/activate
python3 ~/ComfyUI/main.py --listen
# Press Ctrl+A, D to detach
```
Reattach later with `screen -r comfyui`.

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

Each module's page (see [Per-Module Requirements](#per-module-requirements) above) lists its required custom nodes. The fastest path is running `install.sh` / `install.bat` from this repo, which installs all node packs at once.

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

The `install.bat` / `install.sh` scripts download models automatically as part of installation. If a model is missing after install, re-run the same install command — already-downloaded models are skipped and only missing files are fetched. See each module's page (linked in [Per-Module Requirements](#per-module-requirements) above) for exact filenames, sizes, and download sources.

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

**ComfyUI shows a "Missing Node Packs" dialog when loading a workflow**
This is expected if custom nodes aren't installed yet. **Do not click "Install" in the dialog for `ComfyUI-TextureAlchemy`** — ComfyUI Manager installs the wrong branch. Run `install.bat` / `install.sh` instead, which installs all required nodes (including the correct Sandbox branch of TextureAlchemy) automatically.

**ComfyUI shows "Failed to import" or missing node errors**
1. Restart ComfyUI after running `install.bat` / `install.sh`
2. If errors persist, open ComfyUI Manager → Install Missing Custom Nodes
3. For `ComfyUI-TextureAlchemy` specifically, ensure it was cloned from the `Sandbox` branch of [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) — the Manager installs the wrong branch by default

**VRAM out of memory (OOM) during generation**
- Close other GPU applications (browsers with hardware acceleration, games, other AI tools)
- For Wan2.2 modules (09–10): reduce sequence length — stay under 120 frames for 16 GB VRAM
- For Trellis2 (08): reduce output resolution

**Workflow loads but nodes show as red/missing**
The workflow references node types that aren't installed. Run `install.bat` / `install.sh` and restart ComfyUI, then reload the workflow.

**Module 09: first workflow run produces no video**
Module 09 requires two workflows in sequence: run `09-image-cut-out-time-to-move-videoprep.json` first to prepare inputs, then `09-image-cut-out-time-to-move.json` for generation. See the Module 09 README for the full two-step process.

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

**ComfyUI starts but browser on a remote machine can't connect**
By default, ComfyUI only accepts connections from the same machine (`127.0.0.1`). Launch with `--listen` to accept connections from other machines on the network:
```bash
python3 main.py --listen
```
Then open `http://<linux-machine-ip>:8188` in your browser, or set up an SSH tunnel — see the SSH tunnel instructions in the [Linux installation section](#linux) above.
