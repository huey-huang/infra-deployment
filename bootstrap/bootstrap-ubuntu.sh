#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a clean Ubuntu host. Run with sudo privileges from an existing
# provisioning user. The script is intentionally idempotent.
if [[ $EUID -eq 0 ]]; then
  echo "Run this script as the provisioning user; it will invoke sudo." >&2
  exit 1
fi

sudo apt-get update
sudo apt-get install -y ca-certificates curl git jq unzip

if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "Bootstrap complete. Log out and back in for docker-group membership to apply."
