# Custom Nodes — Module 08: Trellis2 3D Asset Gen

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-TRELLIS2 | [PozzettiAndrea/ComfyUI-TRELLIS2](https://github.com/PozzettiAndrea/ComfyUI-TRELLIS2) | `LoadTrellis2Models`, `Trellis2GetConditioning`, `Trellis2ImageToShape`, `Trellis2ShapeToTexturedMesh`, `Trellis2ExportGLB`, `Preview3D` |

ComfyUI-Trellis2 requires pre-built CUDA wheels for its dependencies. The install script handles this automatically for PyTorch 2.7 and 2.8. If installing manually:

```bash
# Windows — pick the folder matching your PyTorch version
cd ComfyUI/custom_nodes/ComfyUI-Trellis2/wheels/Windows/Torch270
pip install *.whl

# Linux — install from requirements.txt (build tools required)
pip install -r ComfyUI/custom_nodes/ComfyUI-Trellis2/requirements.txt
```
