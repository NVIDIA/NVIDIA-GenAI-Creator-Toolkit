# Custom Nodes — Module 07: Panorama to HDRI

> **Important:** Do NOT install `ComfyUI-TextureAlchemy` via ComfyUI Manager — Manager installs the wrong branch. Use the `install.sh` / `install.bat` scripts (recommended), or install it manually with the git command below.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `LuminanceStackProcessor5Stops`, `SaveImageOpenEXR`, `AutoContrastLevels` |

- `LuminanceStackProcessor5Stops` — merges 5 exposure images into HDR using the Debevec algorithm
- `SaveImageOpenEXR` — exports 32-bit EXR / HDRI file
- `AutoContrastLevels` — automatic histogram adjustment per exposure pass

**Manual TextureAlchemy install (Sandbox branch):**

```bash
git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy ComfyUI/custom_nodes/ComfyUI-TextureAlchemy
```
