#!/usr/bin/env bash
set -euo pipefail

curl --fail --silent --show-error "${DIRECTUS_URL:-http://127.0.0.1:8055}/server/ping"
echo

