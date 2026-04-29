# Troubleshooting

## Installation

**`install.bat` does nothing / no output**
Running from Git Bash. Open a Command Prompt (`cmd.exe`) and run from there:
```
install.bat C:\path\to\ComfyUI
```

**`git` is not recognized**
Git is not installed or not in PATH. Install [Git for Windows](https://git-scm.com/downloads) and restart your terminal.

**`hf` is not found** (previously `huggingface-cli`)
Install it with your venv active: `pip install huggingface_hub`
On ComfyUI Portable: `python_embeded\python.exe -m pip install huggingface_hub`

**A model download fails with 403 / "Access restricted"**
The model is gated and requires accepting a HuggingFace data agreement. The installer will pause and show the URL — open it in your browser, accept the agreement, then press Y to continue. Do not press Y before accepting or the download will fail immediately.

## ComfyUI

**A model or LoRA dropdown is empty after install**
ComfyUI scans for model files at startup. If models were downloaded while ComfyUI was already running, the dropdowns will be empty until you restart. Restart ComfyUI and the files will appear. This is the most common cause of empty safetensors or LoRA dropdowns (notably Module 05).

**ComfyUI shows a "Missing Node Packs" dialog when loading a workflow**
ComfyUI Manager scans loaded node types, not the filesystem. If you just ran the installer, the nodes are on disk but ComfyUI hasn't loaded them yet.

- **Already ran the installer:** Close the dialog and restart ComfyUI. The dialog will not appear after restart.
- **Haven't run the installer yet:** Close the dialog and run `install.bat` / `install.sh` first, then restart ComfyUI.

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

## Remote Access

**ComfyUI starts but the browser on a remote machine can't connect**
By default, ComfyUI only accepts connections from the same machine (`127.0.0.1`). Launch with `--listen` to accept connections from other machines on the network:
```bash
# Linux / manual install
python3 main.py --listen

# Windows Portable — add --listen to the python main.py line in run_nvidia_gpu.bat
```
Then open `http://<machine-ip>:8188` in your browser.

For SSH tunnel setup and keeping ComfyUI running after disconnect, see [LINUX_COMFYUI_INSTALLATION.md](LINUX_COMFYUI_INSTALLATION.md).
