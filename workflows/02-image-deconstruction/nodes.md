# Custom Nodes — Module 02: Image Deconstruction

This module uses extended ComfyUI core nodes bundled with the Qwen Image Layered model package. No third-party node packs required beyond the model's companion nodes.

| Node | Source | Purpose |
|------|--------|---------|
| `ReferenceLatent` | Bundled with Qwen Image Layered | Latent reference conditioning |
| `EmptyQwenImageLayeredLatentImage` | Bundled with Qwen Image Layered | Initialize layered latent space |
| `LatentCutToBatch` | Bundled with Qwen Image Layered | Split latent tensor into individual layer outputs |

Install the model via ComfyUI Manager — the companion nodes install automatically alongside it.
