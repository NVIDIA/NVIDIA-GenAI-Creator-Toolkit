# Contributing to ComfyUI Generative AI Workflows

Thank you for your interest in contributing to this project.

## Developer Certificate of Origin (DCO)

This project requires contributors to sign off on their commits under the [Developer Certificate of Origin](https://developercertificate.org/) (DCO version 1.1).

By signing off, you certify that:

1. The contribution was created in whole or in part by you and you have the right to submit it under the Apache 2.0 license.
2. The contribution is based on previous work that, to your knowledge, is covered under an appropriate license and you have the right to submit that work with modifications under Apache 2.0.
3. The contribution was provided to you by someone who certified (1) or (2) above and you have not modified it.
4. You understand and agree that this project and your contributions are public and that a record of the contribution (including your sign-off) is maintained indefinitely.

### How to sign off

Add a `Signed-off-by` trailer to every commit message:

```
git commit -s -m "Your commit message"
```

This produces:

```
Your commit message

Signed-off-by: Your Name <your.email@example.com>
```

Commits without a sign-off will not be merged.

## How to Contribute

1. Fork the repository and create a branch from `main`.
2. Make your changes. Keep commits focused and atomic.
3. Sign off every commit (`git commit -s`).
4. Open a pull request describing what you changed and why.

## Code Style

- Shell scripts: follow existing `set -euo pipefail` conventions in `install.sh`.
- Python: standard library only where possible; no new heavyweight dependencies.
- Workflow JSON: format with 2-space indentation; do not commit model weights or large binaries.

## Reporting Issues

Use [GitHub Issues](../../issues) to report bugs or request features. Include your OS, GPU, ComfyUI version, and the full error output.

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](LICENSE).
