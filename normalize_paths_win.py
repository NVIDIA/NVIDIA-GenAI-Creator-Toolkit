# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
normalize_paths_win.py — normalize ComfyUI workflow JSON model paths for Windows.

Replaces forward-slash model subdirectory prefixes (qwen/, flux/, lotus/) with
Windows backslash equivalents in all *.json files under the given directories.

Called by install.bat after copying workflows to the ComfyUI installation.
Usage: python normalize_paths_win.py <dest_dir1> [dest_dir2 ...]
"""
import sys
import glob
import os
import json

# Known model subdirectory prefixes found in ComfyUI loader widget_values
MODEL_PREFIXES = ["qwen/", "flux/", "lotus/"]


def normalize_file(path):
    with open(path, encoding="utf-8") as f:
        raw = f.read()

    try:
        json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"  [SKIP] {os.path.basename(path)}: not valid JSON ({e})")
        return False

    original = raw
    for prefix in MODEL_PREFIXES:
        # Backslash must be JSON-escaped as \\ in the raw file text.
        # In Python source "\\\\" is two backslash characters, which written
        # to the file produces the two-char sequence \\ that JSON decodes to \.
        win_prefix = prefix.replace("/", "\\\\")
        raw = raw.replace('"' + prefix, '"' + win_prefix)

    if raw == original:
        return False

    try:
        json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"  [ERROR] {os.path.basename(path)}: replacement produced invalid JSON ({e})")
        return False

    with open(path, "w", encoding="utf-8") as f:
        f.write(raw)
    return True


def main():
    if len(sys.argv) < 2:
        print("Usage: normalize_paths_win.py <dir1> [dir2 ...]")
        sys.exit(1)

    patched = 0
    for d in sys.argv[1:]:
        for json_file in sorted(glob.glob(os.path.join(d, "**", "*.json"), recursive=True)):
            changed = normalize_file(json_file)
            if changed:
                print(f"  patched: {os.path.basename(json_file)}")
                patched += 1

    print(f"  {patched} file(s) patched.")


if __name__ == "__main__":
    main()
