#!/usr/bin/bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UNIT_DIR="$REPO_DIR/systemd"
USER_UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

if ! systemctl --user show-environment >/dev/null 2>&1; then
  echo "error: systemd user session unavailable (user bus not running)" >&2
  exit 1
fi

for unit in bdl-update.service bdl-update.timer; do
  sed "s|%h|$HOME|g" "$UNIT_DIR/$unit" >"$USER_UNIT_DIR/$unit"
done

systemctl --user daemon-reload
systemctl --user enable --now bdl-update.timer

echo "Installed. Schedule:"
systemctl --user list-timers bdl-update.timer --all --no-pager