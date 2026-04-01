# Custom Nodes — Module 09: Cutout Animation to Video

| Node / Pack | Source | Purpose |
|-------------|--------|---------|
| TTM Custom Node | DLI course asset | Trajectory mask processing for Wan TTM video generation |
| VideoPrep-Nodes | DLI course asset | Prerequisite helper — generates first/last frames, rough animation pass, and subject mask |
| VideoHelperSuite | [Kosinkadink/ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite) | Video load/save, frame extraction |

**Important:** The VideoPrep-Nodes suite is a direct prerequisite. Run the VideoPrep workflow first to generate the inputs that TTM requires (first frame, last frame, rough 2D trajectory video, subject mask).

VideoPrep-Nodes also solves the "mask drift" problem — it includes a Preview Bridge that preserves painted masks that would otherwise be lost in standard ComfyUI preview nodes.
