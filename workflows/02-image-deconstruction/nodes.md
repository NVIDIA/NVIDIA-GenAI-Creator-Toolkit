# Custom Nodes — Module 02: Image Deconstruction

> **Important:** Do NOT install `ComfyUI-TextureAlchemy` via ComfyUI Manager — Manager installs the wrong branch. Use the `install.sh` / `install.bat` scripts (recommended), or install it manually with the git command below.

For all other packages, ComfyUI Manager → Install Missing Custom Nodes works fine.

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TextureAlchemy | [amtarr/ComfyUI-TextureAlchemy](https://github.com/amtarr/ComfyUI-TextureAlchemy) (branch: `Sandbox`) | `ReferenceLatent`, `EmptyQwenImageLayeredLatentImage`, `LatentCutToBatch`, `ModelSamplingAuraFlow` |
| ComfyUI-WJNodes | [807502278/ComfyUI-WJNodes](https://github.com/807502278/ComfyUI-WJNodes) | Utility nodes |
| ComfyUI-Easy-Use | [yolain/ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | `GetImageSize`, helper nodes |

**Manual TextureAlchemy install (Sandbox branch):**

```bash
git clone --branch Sandbox https://github.com/amtarr/ComfyUI-TextureAlchemy ComfyUI/custom_nodes/ComfyUI-TextureAlchemy
```
