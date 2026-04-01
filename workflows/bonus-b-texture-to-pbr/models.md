# Models — Bonus B: Texture to PBR

## Geometric Maps (Lotus)

| Model | Source | Output |
|-------|--------|--------|
| Lotus Depth | `prs-eth/lotus-depth-g-v1-1` | Depth map |
| Lotus Normal | `prs-eth/lotus-normal-g-v1-1` | Normal map (Height derived from depth) |

## Appearance Decomposition (Marigold)

| Model | Source | Output |
|-------|--------|--------|
| Marigold Appearance | `prs-eth/marigold-appearance` | Roughness, Metallic, Albedo |
| Marigold Light | `prs-eth/marigold-lcm-v1-0` | Lighting/illumination separation |

All four are HuggingFace public models. Total storage: ~8–12 GB depending on variants.

> Note: Gradient shifts are a common issue with Marigold height/depth outputs. The workflow includes padding, cropping, and level adjustment steps to correct this.
