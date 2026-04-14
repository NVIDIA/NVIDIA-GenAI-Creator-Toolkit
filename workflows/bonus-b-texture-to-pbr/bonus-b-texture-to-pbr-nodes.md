# Custom Nodes — Bonus B: Texture to PBR

> **Important:** Do NOT install `ComfyUI-TextureAlchemy` via ComfyUI Manager — Manager installs the wrong branch. Use the `install.sh` / `install.bat` scripts (recommended), or install it manually with the git command below.

For all other packages, ComfyUI Manager → Install Missing Custom Nodes works fine.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-KJNodes | [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `DifferentialDiffusion`, `ModelSamplingAuraFlow` |
| ComfyUI-Easy-Use | [yolain/ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | `GetImageSize`, helper nodes |
| ComfyUI-Inpaint-CropAndStitch | [lquesada/ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch) | Inpainting crop and stitch |
| ComfyUI-Lotus | [kijai/ComfyUI-Lotus](https://github.com/kijai/ComfyUI-Lotus) | `LoadLotusModel`, `LotusSampler` (depth + normal extraction) |
| ComfyUI-Marigold | [kijai/ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold) | Appearance decomposition (Albedo, Roughness, Metallic, Lighting) |

**Manual TextureAlchemy install (Sandbox branch):**

```bash
git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy ComfyUI/custom_nodes/ComfyUI-TextureAlchemy
```
