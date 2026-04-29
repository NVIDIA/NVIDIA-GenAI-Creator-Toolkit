# Linux Installation (ComfyUI + Manager)

You will need three windows open during setup:

| Window | Type | Purpose |
|--------|------|---------|
| SSH window | Command Prompt | Run commands on the Linux machine |
| Tunnel window | PowerShell | Forward port 8188 to your browser |
| Browser | — | Access the ComfyUI UI |

---

**Step 1 — System packages (Ubuntu 24.04):**

In your SSH window:

```bash
sudo apt install git git-lfs ffmpeg libgl1 libglib2.0-0 python3.12-venv screen
```

> `ffmpeg` is required by ComfyUI-VideoHelperSuite for video output. On Windows, it is bundled automatically.

> **CUDA requirement:** ComfyUI requires CUDA 12.x. Ubuntu 24.04 ships with CUDA 12 via the NVIDIA driver package. Verify with `nvidia-smi` — if CUDA Version shows 12.x you're ready. If you installed the driver manually and see CUDA 13+, the installer will downgrade PyTorch to a CUDA 12-compatible build automatically.

---

**Step 2 — Install ComfyUI:**

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

# Install hf CLI (needed for large model downloads)
pip install huggingface_hub
```

---

**Step 3 — Launch ComfyUI:**

Use `screen` so ComfyUI keeps running if your SSH connection drops:

```bash
screen -S comfyui
source ~/ComfyUI/venv/bin/activate
python3 ~/ComfyUI/main.py --listen
```

Once ComfyUI is running, press **Ctrl+A, D** to detach — ComfyUI stays running in the background and your SSH window is free again.

**Restarting ComfyUI** (required after running the workflow installer or installing new modules):

```bash
screen -r comfyui        # reattach to the running session
# press Ctrl+C to stop ComfyUI
python3 ~/ComfyUI/main.py --listen   # start it again
# press Ctrl+A, D to detach
```

> **`--listen` is required on headless Linux machines** — without it, ComfyUI only accepts connections from localhost and the browser tunnel will fail.

---

**Step 4 — Open the SSH tunnel:**

Open a new **PowerShell** window on your Windows machine and run:

```powershell
& "C:\Program Files\Git\usr\bin\ssh.exe" -L 8188:localhost:8188 username@<linux-ip>
```

Keep this PowerShell window open — the tunnel stays active as long as the connection is alive.

---

**Step 5 — Open the UI:**

Open `http://localhost:8188` in your browser.

---

You can now return to your SSH window. Before continuing with the workflow installer, make sure you are in your home directory:

```bash
cd ~
```

Then follow the installer instructions in the main README.
