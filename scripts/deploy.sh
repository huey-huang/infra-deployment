#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENT="${1:-staging}"
DRY_RUN="${DRY_RUN:-true}"
CONFIG_FILE="${CONFIG_FILE:-$ROOT_DIR/environments/${ENVIRONMENT}.env.example}"

[[ -f "$CONFIG_FILE" ]] || { echo "Config not found: $CONFIG_FILE" >&2; exit 1; }
# shellcheck disable=SC1090
. "$CONFIG_FILE"

"$ROOT_DIR/scripts/validate.sh"
echo "Deployment plan: environment=$ENVIRONMENT path=$DEPLOY_PATH project=$COMPOSE_PROJECT_NAME"
echo "Versions: Directus=$DIRECTUS_PLATFORM_VERSION n8n=$N8N_AI_TAGGING_VERSION metadata=$ASSET_METADATA_VERSION"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run only; no remote host was contacted. Set DRY_RUN=false in a reviewed deployment context."
  exit 0
fi

echo "Remote deployment transport is intentionally not configured yet. Use a reviewed SSH or AWS SSM implementation before enabling this path." >&2
exit 2
