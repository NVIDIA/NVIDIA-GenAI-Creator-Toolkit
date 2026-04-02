# Custom Nodes — Module 07: Panorama to HDRI

Install via ComfyUI Manager → Install Missing Custom Nodes.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `LuminanceStackProcessor5Stops`, `SaveImageOpenEXR`, `AutoContrastLevels` |

- `LuminanceStackProcessor5Stops` — merges 5 exposure images into HDR using the Debevec algorithm
- `SaveImageOpenEXR` — exports 32-bit EXR / HDRI file
- `AutoContrastLevels` — automatic histogram adjustment per exposure pass

> **Note:** ComfyUI-TextureAlchemy must be cloned from the `Sandbox` branch. These HDRI-specific nodes are part of the same package used across Modules 02–06 and Bonus A+B.
