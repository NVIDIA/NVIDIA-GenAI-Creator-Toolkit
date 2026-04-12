# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# patch_flash_attn.py — patch Trellis2 dense attention to fall back to torch sdpa
# when flash_attn is not available (e.g. Windows, where no pre-built wheel exists).
#
# The upstream full_attn.py unconditionally imports flash_attn when BACKEND is
# 'flash_attn', causing a hard ModuleNotFoundError on Windows at inference time.
# This script wraps that branch in try/except and falls back to torch sdpa,
# mirroring the pattern already used in trellis2/modules/sparse/attention/full_attn.py.
#
# Usage: python patch_flash_attn.py <ComfyUI-Trellis2-node-dir>
# Called by install.bat during module 08 setup.

import sys
import pathlib

OLD_BLOCK = """\
    elif config.BACKEND == 'flash_attn':
        if 'flash_attn' not in globals():
            import flash_attn
        if num_all_args == 1:
            out = flash_attn.flash_attn_qkvpacked_func(qkv)
        elif num_all_args == 2:
            out = flash_attn.flash_attn_kvpacked_func(q, kv)
        elif num_all_args == 3:
            out = flash_attn.flash_attn_func(q, k, v)\
"""

NEW_BLOCK = """\
    elif config.BACKEND == 'flash_attn':
        try:
            if 'flash_attn' not in globals():
                import flash_attn
            if num_all_args == 1:
                out = flash_attn.flash_attn_qkvpacked_func(qkv)
            elif num_all_args == 2:
                out = flash_attn.flash_attn_kvpacked_func(q, kv)
            elif num_all_args == 3:
                out = flash_attn.flash_attn_func(q, k, v)
        except (ImportError, ModuleNotFoundError):
            # flash_attn not available (e.g. Windows) — fall back to torch sdpa
            if num_all_args == 1:
                q, k, v = qkv.unbind(dim=2)
            elif num_all_args == 2:
                k, v = kv.unbind(dim=2)
            q = q.permute(0, 2, 1, 3)
            k = k.permute(0, 2, 1, 3)
            v = v.permute(0, 2, 1, 3)
            from torch.nn.functional import scaled_dot_product_attention as _sdpa
            out = _sdpa(q, k, v)
            out = out.permute(0, 2, 1, 3)\
"""

SENTINEL = "except (ImportError, ModuleNotFoundError):"


def patch_file(path: pathlib.Path) -> bool:
    """Patch one full_attn.py. Returns True if file was modified."""
    text = path.read_text(encoding="utf-8")
    if SENTINEL in text:
        return False  # already patched
    if OLD_BLOCK not in text:
        print(f"  [WARN] Expected flash_attn block not found in {path}")
        print(f"         The upstream file may have changed. Skipping patch.")
        return False
    patched = text.replace(OLD_BLOCK, NEW_BLOCK, 1)
    path.write_text(patched, encoding="utf-8")
    return True


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: patch_flash_attn.py <ComfyUI-Trellis2-node-dir>")
        sys.exit(1)

    node_dir = pathlib.Path(sys.argv[1])
    target = node_dir / "trellis2" / "modules" / "attention" / "full_attn.py"

    if not target.exists():
        print(f"  [WARN] {target} not found — skipping flash_attn patch.")
        sys.exit(0)

    modified = patch_file(target)
    if modified:
        print(f"  Patched {target}")
    else:
        print(f"  {target} already patched or unchanged.")
