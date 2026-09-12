#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Run as a provisioning user, not root." >&2
  exit 1
fi

echo "Bootstrap placeholder: implementation follows after infrastructure review."

