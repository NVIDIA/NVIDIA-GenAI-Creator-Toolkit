# Custom Nodes — Module 05: Panorama to HDRI

> **Important:** Do NOT install `ComfyUI-TextureAlchemy` via ComfyUI Manager — Manager installs the wrong branch. Use the `install.sh` / `install.bat` scripts (recommended), or install it manually with the git command below.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `LuminanceStackProcessor5Stops`, `AutoContrastLevels` |
| Luminance-Stack-Processor | [sumitchatterjee13/Luminance-Stack-Processor](https://github.com/sumitchatterjee13/Luminance-Stack-Processor) | `LuminanceStackProcessor5Stops` |
| ComfyUI-Marigold | [kijai/ComfyUI-Marigold](https://github.com/kijai/ComfyUI-Marigold) | `SaveImageOpenEXR` |

- `LuminanceStackProcessor5Stops` — merges 5 exposure images into HDR using the Debevec algorithm
- `SaveImageOpenEXR` — exports 32-bit EXR / HDRI file (provided by ComfyUI-Marigold)
- `AutoContrastLevels` — automatic histogram adjustment per exposure pass

**Manual TextureAlchemy install (Sandbox branch):**

```bash
git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy ComfyUI/custom_nodes/ComfyUI-TextureAlchemy
```
