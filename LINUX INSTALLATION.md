# Linux Installation (ComfyUI + Manager)

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
