#!/usr/bin/env python3
"""
audit_urls.py — Check every HuggingFace URL in download_models.py without downloading.
Uses HEAD requests via the HF resolve endpoint and the repo metadata API.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from download_models import build_module_catalogue, ALL_MODULE_KEYS

try:
    import requests
except ImportError:
    print("[ERROR] requests not installed. Run: pip install requests")
    sys.exit(1)

try:
    from huggingface_hub import get_token
    HF_TOKEN = get_token()
except Exception:
    HF_TOKEN = None

HEADERS = {"Authorization": f"Bearer {HF_TOKEN}"} if HF_TOKEN else {}
HF_BASE = "https://huggingface.co"

PASS  = "OK  "
FAIL  = "FAIL"
SKIP  = "SKIP"
WARN  = "WARN"

results = []

def check_repo_exists(repo: str) -> tuple[str, str]:
    """Check if a HuggingFace repo exists via the metadata API."""
    url = f"{HF_BASE}/api/models/{repo}"
    try:
        r = requests.head(url, headers=HEADERS, timeout=15, allow_redirects=True)
        if r.status_code == 200:
            return PASS, f"repo exists ({r.status_code})"
        elif r.status_code == 401:
            return WARN, f"repo exists but gated — need HF login ({r.status_code})"
        elif r.status_code == 403:
            return WARN, f"repo exists but access restricted ({r.status_code})"
        elif r.status_code == 404:
            return FAIL, f"repo NOT FOUND ({r.status_code})"
        else:
            return WARN, f"unexpected status ({r.status_code})"
    except Exception as e:
        return FAIL, f"connection error: {e}"


def check_file_exists(repo: str, filename: str, revision: str = None) -> tuple[str, str]:
    """Check if a specific file exists in a HF repo via a HEAD request."""
    rev = revision or "main"
    url = f"{HF_BASE}/{repo}/resolve/{rev}/{filename}"
    try:
        r = requests.head(url, headers=HEADERS, timeout=15, allow_redirects=True)
        if r.status_code == 200:
            size = r.headers.get("Content-Length", "?")
            return PASS, f"file exists, {int(size)//1024//1024} MB" if size != "?" else f"file exists"
        elif r.status_code == 401:
            return WARN, f"file exists but gated — need HF login ({r.status_code})"
        elif r.status_code == 403:
            return WARN, f"file exists but access restricted ({r.status_code})"
        elif r.status_code == 404:
            return FAIL, f"file NOT FOUND at: {url}"
        elif r.status_code == 302 or r.status_code == 301:
            return PASS, f"file exists (redirect to CDN)"
        else:
            return WARN, f"unexpected status {r.status_code} at: {url}"
    except Exception as e:
        return FAIL, f"connection error: {e}"


def audit():
    catalogue = build_module_catalogue()

    seen = set()
    total = fail = warn = 0

    print()
    print("=" * 72)
    print("  HuggingFace URL Audit")
    print(f"  HF token: {'present' if HF_TOKEN else 'NOT PRESENT — gated files will show WARN'}")
    print("=" * 72)

    for key in ALL_MODULE_KEYS:
        spec = catalogue[key]
        if not spec.models:
            continue

        print(f"\n  [{spec.label}] {spec.name}")
        print(f"  {'-' * 60}")

        for model in spec.models:
            dedup_key = (model.repo, model.filename)
            if dedup_key in seen:
                print(f"  {SKIP}  {model.name}  (shared, already checked)")
                continue
            seen.add(dedup_key)

            total += 1

            if model.full_repo:
                status, msg = check_repo_exists(model.repo)
                label = f"{model.repo} [full repo]"
            else:
                status, msg = check_file_exists(model.repo, model.filename, model.revision)
                label = f"{model.repo} / {model.filename}"

            if status == FAIL:
                fail += 1
            elif status == WARN:
                warn += 1

            flag = " <-- ACTION NEEDED" if status == FAIL else (" <-- check login" if status == WARN else "")
            safe_name  = model.name.encode("ascii", "replace").decode("ascii")
            safe_label = label.encode("ascii", "replace").decode("ascii")
            safe_msg   = msg.encode("ascii", "replace").decode("ascii")
            print(f"  {status}  {safe_name}")
            print(f"        {safe_label}")
            print(f"        {safe_msg}{flag}")

    print()
    print("=" * 72)
    print(f"  SUMMARY: {total} checked  |  {fail} FAILED  |  {warn} WARNINGS  |  {total-fail-warn} OK")
    print("=" * 72)
    print()

    if fail > 0:
        print("  FAILED URLs need fixing before users can install.")
    if warn > 0:
        print("  WARNINGS: gated files require HF login. Run with a token to confirm.")
    if fail == 0 and warn == 0:
        print("  All URLs verified.")
    print()


if __name__ == "__main__":
    audit()
