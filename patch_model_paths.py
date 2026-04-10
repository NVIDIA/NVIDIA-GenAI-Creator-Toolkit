# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# patch_model_paths.py — replace forward slashes with backslashes in model path
# strings inside workflow JSON files, so ComfyUI on Windows can locate models.
#
# ComfyUI on Windows uses os.walk, which returns backslash-separated paths.
# Workflow JSONs authored on Linux use forward slashes. This script converts them
# at install time so users do not have to edit workflows manually.
#
# Usage: python patch_model_paths.py <workflows_dest_dir>

import re
import sys
import pathlib

PATTERN = re.compile(r'([a-z]+)/([^/\s"]+\.(?:safetensors|pth|ckpt|pt))')

def patch_dir(directory):
    patched_count = 0
    for f in pathlib.Path(directory).rglob("*.json"):
        text = f.read_text(encoding="utf-8")
        result = PATTERN.sub(lambda m: m.group().replace("/", "\\\\"), text)
        if result != text:
            f.write_text(result, encoding="utf-8")
            patched_count += 1
    return patched_count

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: patch_model_paths.py <workflows_dir>")
        sys.exit(1)
    n = patch_dir(sys.argv[1])
    print(f"  Patched model paths in {n} workflow file(s).")
