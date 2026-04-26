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
MODEL_PREFIXES = ["qwen/", "flux/", "lotus/", "models/sam3/"]


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
