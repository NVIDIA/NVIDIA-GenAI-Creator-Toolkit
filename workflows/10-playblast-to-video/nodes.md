# Custom Nodes — Module 10: Playblast to Video

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-WanVideoWrapper | [kijai/ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | `WanVideoModelLoader`, `WanVideoVACEEncode`, `WanVideoSampler`, `WanVideoDecode`, `WanVideoExtraModelSelect` and related |
| ComfyUI-VideoHelperSuite | [Kosinkadink/ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | `VHS_LoadVideo`, `VHS_VideoCombine`, `VHS_VideoInfo` |
| ComfyUI-KJNodes | [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) | `ImageResizeKJv2`, `GetImageSizeAndCount`, `FloatConstant`, `INTConstant`, `StringToFloatList` |
| ComfyUI-Lotus | [kijai/ComfyUI-Lotus](https://github.com/kijai/ComfyUI-Lotus) | `LoadLotusModel`, `LotusSampler` (depth estimation from video frames) |
| radiance | [fxtdstudios/radiance](https://github.com/fxtdstudios/radiance) | `FXTDAIUpscale`, `FXTDFilmLook`, `FXTDProUpscale` |
| cg-use-everywhere | [chrisgoringe/cg-use-everywhere](https://github.com/chrisgoringe/cg-use-everywhere) | `Seed Everywhere` |
| ComfyUI-Custom-Scripts | [pythongosssss/ComfyUI-Custom-Scripts](https://github.com/pythongosssss/ComfyUI-Custom-Scripts) | `StringFunction\|pysssss` |
| ComfyUI-post-processing-nodes | [EllangoK/ComfyUI-post-processing-nodes](https://github.com/EllangoK/ComfyUI-post-processing-nodes) | Post-processing image/video effects |
| ComfyUI-VideoUpscale_WithModel | [ShmuelRonen/ComfyUI-VideoUpscale_WithModel](https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel) | `Video_Upscale_With_Model` |

> This workflow uses **WAN VACE** (Video Annotated Conditioning for Editing) for video-conditioned generation. Lotus handles depth estimation from the input video frames for conditioning — no separate depth pass export from your 3D application is required.
