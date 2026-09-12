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
  [[ "$value" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || {
    echo "Invalid or missing $key in $manifest" >&2
    exit 1
  }
done

for config in environments/staging.env.example environments/production.env.example; do
  for key in DIRECTUS_DEPLOY_PATH N8N_DEPLOY_PATH METADATA_DEPLOY_PATH; do
    grep -q "^${key}=" "$config" || { echo "Missing $key in $config" >&2; exit 1; }
  done
done

bash -n bootstrap/bootstrap-ubuntu.sh scripts/deploy.sh scripts/healthcheck.sh
echo "Validation passed."
