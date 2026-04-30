# Custom Nodes — Module 04: Equirectangular Outpainting

Install via ComfyUI Manager → Install Missing Custom Nodes.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `TextureOffset`, `DifferentialDiffusion`, `ModelSamplingAuraFlow` |
| ComfyUI-Easy-Use | [yolain/ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | Various utility nodes |
| ComfyUI-Inpaint-CropAndStitch | [lquesada/ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch) | `InpaintCropImproved` |
| ComfyUI-KJNodes | [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | `CreateShapeMask` (used in subgraph) |

> **Note:** ComfyUI-TextureAlchemy must be cloned from the `Sandbox` branch. `TextureOffset` wraps the image horizontally to eliminate the seam at the panorama boundary before inpainting.
