# Custom Nodes — Module 08: Trellis2 3D Asset Gen

| Node Pack | Repo | Key Nodes |
|-----------|------|-----------|
| ComfyUI-Trellis2 | [visualbruno/ComfyUI-Trellis2](https://github.com/visualbruno/ComfyUI-Trellis2) | `Trellis2LoadModel`, `Trellis2LoadImageWithTransparency`, `Trellis2PreProcessImage`, `Trellis2MeshWithVoxelGenerator`, `Trellis2FillHolesWithCuMesh`, `Trellis2ReconstructMeshWithQuad`, `Trellis2SimplifyMesh`, `Trellis2FillHolesWithMeshlib`, `Trellis2UnWrapAndRasterizer`, `Trellis2ExportMesh` |

ComfyUI-Trellis2 requires pre-built CUDA wheels for its dependencies. The install script handles this automatically for PyTorch 2.7 and 2.8. If installing manually:

```bash
# Windows — pick the folder matching your PyTorch version
cd ComfyUI/custom_nodes/ComfyUI-Trellis2/wheels/Windows/Torch270
pip install *.whl

# Linux — install from requirements.txt (build tools required)
pip install -r ComfyUI/custom_nodes/ComfyUI-Trellis2/requirements.txt
```
