# Custom Nodes — Module 06: Cutout Animation to Video

Two workflows are included: `09-cutout-animation-to-video-videoprep.json` (run first) and `09-cutout-animation-to-video.json` (TTM generation).

## VideoPrep workflow (`09-cutout-animation-to-video-videoprep.json`)

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

## TTM workflow (`09-cutout-animation-to-video.json`)

| Node Pack | Repo | Purpose |
|-----------|------|---------|
| ComfyUI-WanVideoWrapper | [kijai/ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | Wan2.2 VACE video sampler, model loader, decoder |
| ComfyUI-KJNodes | [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | Utility nodes |
| ComfyUI-Impact-Pack | [ltdrdata/ComfyUI-Impact-Pack](https://github.com/ltdrdata/ComfyUI-Impact-Pack) | `ImpactSwitch` (conditional routing) |
| ComfyUI-VideoHelperSuite | [Kosinkadink/ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O |
| ComfyUI_essentials | [cubiq/ComfyUI_essentials](https://github.com/cubiq/ComfyUI_essentials) | Utility nodes |
| ComfyUI-Easy-Use | [yolain/ComfyUI-Easy-Use](https://github.com/yolain/ComfyUI-Easy-Use) | Utility nodes |
| ComfyUI-Custom-Scripts | [pythongosssss/ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts) | `StringFunction\|pysssss` |

**Run VideoPrep first.** It generates the first frame, last frame, trajectory video, and subject mask that `09-cutout-animation-to-video.json` requires as inputs.
