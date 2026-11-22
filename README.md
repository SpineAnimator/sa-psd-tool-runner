# SA PSD Tool Runner

This repository contains the reusable PSD validation workflow and a Dockerized **self-hosted GitHub Actions runner** bootstrap.

The runner is scoped to the private target repository:

`SpineAnimator/spine-animator-private`

It advertises these labels:

- `self-hosted`
- `linux`
- `x64`
- `sa-psd-tool-runner`

## Important distinction

The workflow smoke test in this repository uses GitHub-hosted `ubuntu-latest`. It proves that GitHub-hosted execution works for this public repository. It does **not** register a self-hosted runner and does not make that runner available to the private repository.

The Docker image below is the self-hosted runner host software. It must run on a separate, always-on Linux machine or VM. Do not install it on the user's iMac.

## Register the self-hosted runner

1. On a dedicated Linux x64 host with Docker Engine and Docker Compose installed, open the private repository's **Settings → Actions → Runners → New self-hosted runner**.
2. Select Linux and x64. GitHub will show a short-lived registration token. Generate it immediately before first startup; it expires after a short period.
3. Clone this repository on the Linux host and create a local `.env` file (never commit it):

   ```dotenv
   RUNNER_TOKEN=PASTE_THE_SHORT_LIVED_REGISTRATION_TOKEN_HERE
   ```

4. Start the runner:

   ```bash
   docker compose up -d --build
   docker compose logs -f
   ```

5. Confirm that GitHub lists `sa-psd-tool-runner-01` as **Online** in the private repository's Runners settings.
6. After registration succeeds, remove the token from the host's `.env` file. The named Docker volume `runner-data` persists the runner registration across container restarts.

The runner is repository-scoped to `spine-animator-private`; do not point it at the public runner repository. Keep it online while jobs are expected.

## Workflow integration

The reusable workflow `.github/workflows/psd-validation.yml` is called by the private repository and targets the labels above. The public repository's smoke job remains on GitHub-hosted Ubuntu and is only a container-image build check.

## Security

- Never commit a registration token, personal access token, private key, or `.env` file.
- Do not expose this runner to untrusted repositories or untrusted pull-request code.
- Keep the runner dedicated to the private PSD pipeline and keep the host patched.
- The runner container persists its registration in the `runner-data` volume. Removing that volume removes the local registration state; remove the runner from GitHub's Runners settings before destroying a host permanently.
