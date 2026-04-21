"""Convert MP4 to an optimized preview GIF using imageio + PIL."""
import sys
import imageio.v3 as iio
from PIL import Image, ImageSequence
import io

SRC = r"C:\Users\jpennington\OneDrive - NVIDIA Corporation\Documents\ComfyUI\GTC-DLI-20260402T012354Z-3-001\GTC-DLI\HANDOFF\Source Content\VIdeo\Frog\Extended Final Banner\extension3.mp4"
DST = r"C:\Users\jpennington\Creative-GenAI-Workflows\workflows\10-video-to-video\images\preview.gif"

TARGET_W = 480
FRAME_STEP = 4   # keep every Nth frame
GIF_FPS = 10

print("Reading video frames...")
frames_raw = iio.imread(SRC, plugin="pyav", index=None)  # shape (N, H, W, 3)
print(f"  {len(frames_raw)} frames, {frames_raw.shape[2]}x{frames_raw.shape[1]}")

sampled = frames_raw[::FRAME_STEP]
print(f"  Sampled down to {len(sampled)} frames (every {FRAME_STEP})")

h, w = sampled.shape[1], sampled.shape[2]
new_w = TARGET_W
new_h = int(h * new_w / w)
print(f"  Resizing to {new_w}x{new_h}")

pil_frames = []
for f in sampled:
    img = Image.fromarray(f).resize((new_w, new_h), Image.LANCZOS)
    # Quantize to 256-color palette
    img = img.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG)
    pil_frames.append(img)

duration_ms = int(1000 / GIF_FPS)
print(f"  Writing GIF ({len(pil_frames)} frames @ {GIF_FPS}fps)...")
pil_frames[0].save(
    DST,
    save_all=True,
    append_images=pil_frames[1:],
    loop=0,
    duration=duration_ms,
    optimize=True,
)

import os
size_mb = os.path.getsize(DST) / 1024 / 1024
print(f"Done: {DST} ({size_mb:.1f} MB)")
