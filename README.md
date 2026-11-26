# SA PSD Tool Runner

This repository is a **public GitHub-hosted Actions workflow provider** for PSD/PSB and Spine 4.3 validation. It does not register, host, or manage self-hosted runners.

## Execution model

- All jobs use GitHub-hosted `ubuntu-24.04` runners.
- The reusable workflow `.github/workflows/psd-validation.yml` accepts an exact `source-repository` and `source-ref`.
- A public orchestrator (for example `SpineAnimator/2Spine-visual-audit`) can call it with `secrets: inherit`; the job then checks out the requested private source using the caller's `SOURCE_REPO_TOKEN`.
- PSD validation runs in an ephemeral GitHub-hosted Ubuntu environment and uploads no source PSDs or private project files.
- The runner repository's own push checks validate the public-runner contract only.

## Reusable workflow inputs

- `source-repository`: optional source repository in `owner/name` form. Leave empty to validate the calling repository.
- `source-ref`: exact branch, tag, or commit. Defaults to `main`.
- `SOURCE_REPO_TOKEN`: required only when checking out a private source repository.

## Security

- No runner registration tokens, long-lived runner processes, Dockerized self-hosted runners, or persistent runner volumes are used.
- The checkout uses `persist-credentials: false`.
- Private source access is read-only and provided by the public caller's Actions secret; secrets are never printed.
- Public runner code is orchestration and validation logic only; private PSDs and derived assets remain ephemeral on the hosted runner.
