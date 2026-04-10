# Custom Nodes — Module 09: Cutout Animation to Video

Two workflows are included: `videoprep.json` (run first) and `workflow.json` (TTM generation).

## VideoPrep workflow (`videoprep.json`)

| Node Pack | Repo | Purpose |
|-----------|------|---------|
| comfy_nv_video_prep | [NVIDIA/comfy_nv_video_prep](https://github.com/NVIDIA/comfy_nv_video_prep) | TTM trajectory mask prep, SAM2-based click-to-segment, mask bridge |
| ComfyUI-KJNodes | [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| ComfyUI-Custom-Scripts | [pythongosssss/ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts) | `StringFunction|pysssss` |
| ComfyUI_essentials | [cubiq/ComfyUI_essentials](https://github.com/cubiq/ComfyUI_essentials) | Utility nodes |
| ComfyUI-Inpaint-CropAndStitch | [lquesada/ComfyUI-Inpaint-CropAndStitch](https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch) | Inpainting crop/stitch |
| comfyui-sam2 | [neverbiasu/ComfyUI-SAM2](https://github.com/neverbiasu/ComfyUI-SAM2) | Click-to-segment subject mask |
| ComfyUI-SAM3 | [PozzettiAndrea/ComfyUI-SAM3](https://github.com/PozzettiAndrea/ComfyUI-SAM3) | SAM3 segmentation model loader |
| ComfyUI-VideoHelperSuite | [Kosinkadink/ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O, frame extraction |

## TTM workflow (`workflow.json`)

Reuses the same node packs as VideoPrep — no additional installs required.

**Run VideoPrep first.** It generates the first frame, last frame, trajectory video, and subject mask that `workflow.json` requires as inputs.
