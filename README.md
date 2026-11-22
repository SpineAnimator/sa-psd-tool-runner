# SA PSD Tool Runner

This repository provides the reusable GitHub Actions workflow for native PSD/PSB and Spine 4.3 validation in:

`SpineAnimator/spine-animator-private`

## Active execution model

The private caller invokes `.github/workflows/psd-validation.yml`. Its validation job runs on a repository-scoped self-hosted **macOS x64** runner with labels:

`self-hosted, macOS, X64, sa-psd-tool-runner`

The currently registered host is the user's explicitly authorized iMac. It is configured as a per-user macOS LaunchAgent under the runner account and is expected to start when that user session is active. It is not a Linux host and must not be described as one.

The workflow checks out the exact caller commit and runs Node.js 22, Python 3.11, `psd-tools`, Pillow, the v7.54 semantic exporter tests, PSD/PSB tree extraction tests, ZIP/raster packaging tests, and native-composite fail-closed checks.

## Scope and limits

- This runner is used for source-level and PSD processing CI only.
- It does **not** launch Spine Editor or perform an official Spine Pro 4.3 GUI/runtime import.
- A successful CI run is not evidence of Photoshop pixel parity or full Spine import compatibility.
- Do not use this host for local Spine Editor validation.
- The Dockerfile and `compose.yaml` remain optional templates for a future dedicated Linux x64 host. They are not used by the active macOS runner.

## Security

- The runner is repository-scoped to `SpineAnimator/spine-animator-private`.
- Never commit a runner registration token, PAT, private key, or `.env` file.
- The reusable workflow has read-only repository permissions.
- Do not expose this runner to untrusted repositories or untrusted workflow code.
- Private source PSDs and derived assets remain in the private caller repository / its private workflow context.
- Public runner code contains orchestration only; it must not store original PSDs, source layers, or license material.
