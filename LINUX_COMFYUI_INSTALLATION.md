# Linux Installation (ComfyUI + Manager)

**System packages (Ubuntu 24.04):**

```bash
sudo apt install git git-lfs ffmpeg libgl1 libglib2.0-0 python3.12-venv screen
```

> `ffmpeg` is required by ComfyUI-VideoHelperSuite for video output. On Windows, it is bundled automatically.

> **CUDA requirement:** ComfyUI requires CUDA 12.x. Ubuntu 24.04 ships with CUDA 12 via the NVIDIA driver package. Verify with `nvidia-smi` — if CUDA Version shows 12.x you're ready. If you installed the driver manually and see CUDA 13+, the installer will downgrade PyTorch to a CUDA 12-compatible build automatically.

```bash
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI

# Create and activate a virtual environment (required on Linux)
# python3 is Python 3.12 on Ubuntu 24.04
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

**Launch ComfyUI:**

Use `screen` so ComfyUI keeps running if your SSH connection drops:

```bash
screen -S comfyui
source ~/ComfyUI/venv/bin/activate
python3 ~/ComfyUI/main.py --listen
```

Press **Ctrl+A, D** to detach from the screen session — ComfyUI stays running in the background. Reattach later with `screen -r comfyui`.

> **`--listen` is required on headless Linux machines** — without it, ComfyUI only accepts connections from localhost and the browser tunnel will fail.

**Accessing the UI from a remote Windows machine (SSH tunnel):**

Open a new PowerShell window on your Windows machine and run:

```powershell
& "C:\Program Files\Git\usr\bin\ssh.exe" -L 8188:localhost:8188 username@<linux-ip>
```

Then open `http://localhost:8188` in your browser. Keep this Command Prompt window open — the tunnel stays active as long as the connection is alive.
