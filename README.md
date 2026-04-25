# ComfyUI Generative AI Workflows

**Achieve professional creative control over 3D assets and motion for visualization, powered by modular generative AI pipelines on NVIDIA RTX.**

Adapted from NVIDIA's GTC 2026 DLI course [*Create Generative AI Workflows for Design and Visualization in ComfyUI*](https://www.nvidia.com/en-us/on-demand/session/gtc26-dlit81948/) (DLIT81948). Each module is standalone — pick the pipelines that fit your work.

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![GPU](https://img.shields.io/badge/GPU-NVIDIA%20RTX%20required-76b900)
![License](https://img.shields.io/badge/license-Apache%202.0-green)

![](docs/overview.png)

---

## Requirements

- **GPU:** RTX 5090 (32 GB) or larger recommended
- **OS:** Windows 11 or Linux x86_64
- **Software:** [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + [ComfyUI Manager](https://github.com/ltdrdata/ComfyUI-Manager)

See [REQUIREMENTS.md](REQUIREMENTS.md) for full hardware/software details and per-module VRAM and generation time estimates.

### Storage

| Module Group | Approx. Storage |
|---|---|
| Modules 01–06, Bonus A (Qwen stack, shared) | ~30 GB |
| Module 07 (Flux Dev Kontext) | ~25 GB |
| Module 08 (Trellis2) | ~20 GB |
| Modules 09–10 (Wan2.2) | ~40 GB |
| Bonus B (Lotus + Marigold) | ~12 GB |
| **All modules (shared models counted once)** | **~160–180 GB** |

You only need to download models for the modules you install. Start small — see [Recommended Starting Point](REQUIREMENTS.md#recommended-starting-point).

---

## Quick Start

> **New to ComfyUI?** ComfyUI is a node-based generative AI interface — you connect model components visually to build pipelines. Think of it like a visual programming tool for AI. Each workflow in this repo is a pre-built pipeline you load and run.

```bash
# 0. Install ComfyUI first (if you haven't already)
#    Windows: download and install from https://www.comfy.org/download
#             (use the desktop app — it handles Python, CUDA, and updates automatically)
#    Linux:   see REQUIREMENTS.md for step-by-step setup
#    Then launch ComfyUI and confirm it opens at http://127.0.0.1:8188

# 1. Clone this repo
git clone https://github.com/NVIDIA/NVIDIA-GenAI-Creator-Toolkit
cd NVIDIA-GenAI-Creator-Toolkit

# 2. Install custom nodes and download models
#    Pass your ComfyUI installation location — the folder you chose during Desktop App setup.
#    It contains your .venv\, models\, and custom_nodes\ folders.
#    Not sure where it is? Check Desktop App Settings > Installation Location.
#
# Windows (run from Command Prompt, NOT Git Bash or PowerShell):
#   Pass the installation location you chose when setting up the Desktop App.
#   Find it in: Desktop App Settings > Installation Location
install.bat C:\path\to\your\installation-location

# Linux:
bash install.sh /path/to/ComfyUI
```

> **Finding your installation location:** This is the folder you chose when setting up the [ComfyUI Desktop App](https://www.comfy.org/download) — it contains your `.venv\`, `models\`, and `custom_nodes\` folders. Check **Settings → Installation Location** inside the app if you're unsure.

> **New to this?** Don't download everything at once — see [Recommended Starting Point](REQUIREMENTS.md#recommended-starting-point) in REQUIREMENTS.md for a low-friction first module to try.

### Adding more modules later

Run the same script again with `--modules` and the module number. Already-installed nodes are skipped automatically.

```bash
# Windows:
install.bat C:\path\to\ComfyUI --modules 05
# Linux:
bash install.sh /path/to/ComfyUI --modules 05
```

---

## Loading a Workflow

1. Open ComfyUI in your browser (`http://127.0.0.1:8188`)
2. Drag the `.json` file onto the canvas, or use **Open** in the ComfyUI menu
3. If ComfyUI shows a **Missing Models** dialog, the listed files need to be downloaded before generating. Re-run `install.bat` / `install.sh` — already-downloaded models are skipped and only missing files are fetched.

**Connecting images:** Most workflows include a **Load Image** node. Click the **upload** button on the node to choose a file, or drag an image file directly onto the canvas — ComfyUI will route it to the active Load Image node. Each module's `input/` folder contains sample images to get started.

**Module 09 — two workflows:** Load and run `09-image-cut-out-time-to-move-videoprep.json` first to prepare your inputs. Then load `09-image-cut-out-time-to-move.json` and connect the VideoPrep outputs before queuing.

---

## Workflows

> **VRAM — Windows / Linux.** On Windows, NVIDIA weight streaming offloads inactive model layers to system RAM. On Linux, the full model must fit in VRAM. See [REQUIREMENTS.md](REQUIREMENTS.md) for platform details.

### Core Modules

| # | Workflow | Key Model(s) | VRAM | What It Does |
|---|----------|-------------|------|--------------|
| 01 | [LLM Prompt Enhancer](modules/01-llm-prompt-enhancer.md) | Gemma 3 via Ollama | 16 / 32 GB | Build an AI agent that refines weak prompts into model-ready instructions |
| 02 | [Image Deconstruction](modules/02-image-deconstruction.md) | Qwen Image Layered | 16 / 32 GB | Split any image into foreground, midground, and background layers |
| 03 | [Targeted Inpainting](modules/03-targeted-inpainting.md) | Qwen Image Edit 2511 | 16 / 32 GB | Mask-and-patch editing — change only the pixels you select |
| 04 | [Image → Gaussian Splat](modules/04-image-to-gaussian-splat.md) | SHARP | 12 GB | Convert a 2D image into a navigable 3D Gaussian point cloud |
| 05 | [Novel View Synthesis](modules/05-novel-view-synthesis.md) | Qwen Image Edit 2511 + LoRA | 16 / 32 GB | Fill occluded areas in Gaussian Splat output for full camera freedom |
| 06 | [Image → Equirectangular](modules/06-image-to-equirectangular.md) | Qwen Image Edit 2511 + MikMumpitz 360 LoRA | 16 / 32 GB | Turn a single image into a seamless 360° panorama |
| 07 | [Panorama → HDRI](modules/07-panorama-to-hdri.md) | Flux Dev Kontext + Exposure LoRAs | 16 / 32 GB | Generate a production-ready HDRI from a panoramic image |
| 08 | [Image to 3D](modules/08-image-to-3d.md) | Trellis2 | 24 GB | Convert a 2D reference into a textured 3D model with PBR materials |
| 09 | [Image Cut Out Time to Move](modules/09-image-cut-out-time-to-move.md) | Wan2.2 TTM + VideoPrep | 24 / 32 GB | Trajectory-controlled video — define exactly when and where motion happens |
| 10 | [Video to Video](modules/10-video-to-video.md) | Wan2.2 VACE + Lotus | 24 GB / 48 GB+ | Transform a basic 3D render into stylized video — depth extracted automatically |

### Bonus Modules

| | Workflow | Key Model(s) | VRAM | What It Does |
|--|----------|-------------|------|--------------|
| B-A | [Texture Extraction](modules/bonus-a-texture-extraction.md) | Qwen Image Edit 2511 + Texture LoRA | 16 / 32 GB | Extract seamless tileable textures from any image |
| B-B | [Texture → PBR](modules/bonus-b-texture-to-pbr.md) | Lotus + Marigold | 16 / 32 GB | Generate a full PBR material set (Normal, Height, Albedo, Roughness, Metallic) |

---

## How Each Workflow Is Organized

Every module has a page in [`modules/`](modules/) with its requirements, models, custom nodes, and troubleshooting. The workflow folder contains the ComfyUI JSON and usage instructions:

```
modules/
└── 01-llm-prompt-enhancer.md     ← models, nodes, troubleshooting

workflows/01-llm-prompt-enhancer/
├── README.md                     ← usage instructions and sample inputs
└── 01-llm-prompt-enhancer.json   ← drag this into ComfyUI
```

Module 09 includes two workflows — run `09-image-cut-out-time-to-move-videoprep.json` first, then `09-image-cut-out-time-to-move.json`.

---

## Module Dependencies

Some modules build on each other:

```
04 Image → Gaussian Splat
└── 05 Novel View Synthesis

06 Image → Equirectangular
└── 07 Panorama → HDRI

VideoPrep (helper)
└── 09 Image Cut Out Time to Move

Bonus A Texture Extraction
└── Bonus B Texture → PBR
```

All other modules are fully standalone.

---

## License

Code and documentation in this repository are licensed under [Apache 2.0](LICENSE).

Model licenses vary — see each module's page in [`modules/`](modules/) for details. Notable exception: **Flux.1-dev** (Module 07) requires a separate license from Black Forest Labs for commercial use.

> **Third-party software notice:** This project will download and install additional third-party open source software projects. Review the license terms of these open source projects before use. See [THIRD-PARTY.txt](THIRD-PARTY.txt) for the full list.

---

## Credits

Course developed by Alessandro La Tona, Ashlee Martino-Tarr, Daniela Flamm Jackson, and Guillaume Polaillon.
