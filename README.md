# SA PSD Tool Runner

This repository provides a reusable GitHub Actions workflow for native PSD/PSB and Spine 4.3 validation in the private project:

`SpineAnimator/spine-animator-private`

## Default execution model

The reusable workflow `.github/workflows/psd-validation.yml` runs the private caller's validation jobs on an ephemeral GitHub-hosted `ubuntu-24.04` runner. It checks out the exact caller commit, installs Node.js 22 plus Python 3.11 / `psd-tools`, then runs the PSD tree, v7.54 exporter, raster packaging, and fail-closed composite tests.

No persistent self-hosted runner, registration token, PAT, or user computer is required for the default validation path. The caller's `GITHUB_TOKEN` is limited to read access.

## Optional self-hosted image

The Dockerfile and `compose.yaml` remain as an optional deployment template for a dedicated Linux x64 host. They are not required by the default reusable workflow.

If a self-hosted deployment is ever chosen, it must run on a separate, always-on Linux VM with a repository-scoped runner registration token generated immediately before startup. **Do not install this runner on the user's iMac.** Keep it dedicated to the private PSD pipeline and do not expose it to untrusted repositories or pull-request code.

The public repository's `runner-smoke` job only builds and validates this optional image. It does not register a self-hosted runner and does not claim that one is online.

## Security

- Never commit a runner registration token, PAT, private key, or `.env` file.
- The reusable workflow uses read-only repository permissions.
- Private source PSDs and derived assets must remain in the private caller repository / its private workflow context.
- Public runner code contains orchestration only; it must not store original PSDs, source layers, or license material.
