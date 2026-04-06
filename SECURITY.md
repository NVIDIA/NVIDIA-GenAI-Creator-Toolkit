# Security Policy

## Supported Versions

This project provides ComfyUI workflow configurations and installer utilities. Security fixes are applied to the latest version on the `main` branch only.

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub Issues.**

To report a security issue, please use the GitHub Security Advisory ["Report a Vulnerability"](../../security/advisories/new) feature, or email the NVIDIA Product Security team at:

**psirt@nvidia.com**

Include as much of the following as possible:

- Type of issue (e.g., command injection, path traversal, dependency with known CVE)
- Full paths to source files related to the issue
- Steps to reproduce
- Proof-of-concept or exploit code (if available)
- Impact assessment

NVIDIA PSIRT will acknowledge receipt within 3 business days and provide a more detailed response within 10 business days indicating next steps.

## Scope

This repository contains:
- Shell scripts that clone public GitHub repositories via `git clone`
- A Python utility that downloads models from HuggingFace via `huggingface-cli`
- ComfyUI workflow JSON files (no executable code)

The scripts execute third-party code (ComfyUI custom nodes) and download large model files. Users should review the licenses and security posture of those third-party dependencies independently.
