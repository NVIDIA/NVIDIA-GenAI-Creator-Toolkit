# Custom Nodes — Module 10: Playblast to Video

| Node Pack | Repo | Purpose |
|-----------|------|---------|
| ComfyUI-WanVideoWrapper | [kijai/ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | Wan2.2 model loading and Vid2Vid generation |
| VideoHelperSuite | [Kosinkadink/ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video I/O, frame extraction |
| comfyui_controlnet_aux | [Fannovel16/comfyui_controlnet_aux](https://github.com/Fannovel16/comfyui_controlnet_aux) | Canny edge extraction from beauty render |

**External requirement:** Your 3D application (Blender, Maya, Cinema 4D, Unreal) must export:
1. Beauty/color render video
2. Depth pass video (normalized Z-depth)
3. Canny/Edge pass (can be generated in-workflow from the beauty render using comfyui_controlnet_aux)
