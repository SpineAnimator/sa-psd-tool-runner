#!/usr/bin/env bash
set -euo pipefail

cd /runner

if [[ ! -x ./config.sh ]]; then
  case "$(uname -m)" in
    x86_64) runner_arch="x64" ;;
    aarch64|arm64) runner_arch="arm64" ;;
    *)
      echo "Unsupported runner architecture: $(uname -m)" >&2
      exit 2
      ;;
  esac

  release_json="$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest)"
  version="$(printf '%s' "$release_json" | jq -r '.tag_name | ltrimstr("v")')"
  asset="actions-runner-linux-${runner_arch}-${version}.tar.gz"
  download_url="$(printf '%s' "$release_json" | jq -r --arg asset "$asset" '.assets[] | select(.name == $asset) | .browser_download_url' | head -n 1)"
  if [[ -z "$download_url" || "$download_url" == "null" ]]; then
    echo "Could not find GitHub Actions runner asset: $asset" >&2
    exit 3
  fi

  curl -fL "$download_url" -o runner.tar.gz
  tar xzf runner.tar.gz
  rm runner.tar.gz
fi

if [[ ! -f .runner ]]; then
  : "${RUNNER_TOKEN:?RUNNER_TOKEN is required for first-time registration}"
  runner_url="${RUNNER_URL:-https://github.com/SpineAnimator/spine-animator-private}"
  runner_name="${RUNNER_NAME:-sa-psd-tool-runner-$(hostname)}"
  runner_labels="${RUNNER_LABELS:-sa-psd-tool-runner,linux,x64}"

  ./config.sh \
    --url "$runner_url" \
    --token "$RUNNER_TOKEN" \
    --name "$runner_name" \
    --labels "$runner_labels" \
    --work "_work" \
    --unattended \
    --replace
fi

unset RUNNER_TOKEN || true
exec ./run.sh
