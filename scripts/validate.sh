#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v awk >/dev/null || { echo "awk is required" >&2; exit 1; }

manifest="manifests/versions.yaml"
required_keys=(directus_platform n8n_ai_tagging asset_metadata_service)
for key in "${required_keys[@]}"; do
  value="$(awk -F': *' -v k="$key" '$1 == k { print $2 }' "$manifest")"
  [[ "$value" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    echo "Invalid or missing $key in $manifest" >&2
    exit 1
  }
done

bash -n bootstrap/bootstrap-ubuntu.sh scripts/deploy.sh scripts/healthcheck.sh
echo "Validation passed."
