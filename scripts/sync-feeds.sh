#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-feeds.sh [options] [feedname...]

Synchronize OpenWrt/LEDE feeds using ./scripts/feeds.

By default, this script updates AND installs all feeds (-a).
If one or more feed names are provided, only those feeds are synced.

Options:
  --update-only     Only run "feeds update" (no install)
  --install-only    Only run "feeds install" (no update)
  -f, --force       Force "feeds update" (passes -f)
  -h, --help        Show this help

Examples:
  scripts/sync-feeds.sh
  scripts/sync-feeds.sh --update-only
  scripts/sync-feeds.sh packages luci
  scripts/sync-feeds.sh --force passwall_packages passwall_luci
EOF
}

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$TOPDIR"

if [[ ! -x ./scripts/feeds ]]; then
  echo "Error: ./scripts/feeds not found or not executable (TOPDIR=$TOPDIR)" >&2
  exit 1
fi

do_update=1
do_install=1
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --update-only) do_install=0; shift ;;
    --install-only) do_update=0; shift ;;
    -f|--force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

feeds=("$@")

update_args=()
install_args=()
if [[ "${#feeds[@]}" -eq 0 ]]; then
  update_args+=("-a")
  install_args+=("-a")
else
  update_args+=("${feeds[@]}")
  install_args+=("-a")
  for f in "${feeds[@]}"; do
    install_args+=("-p" "$f")
  done
fi

if [[ "$do_update" -eq 1 ]]; then
  echo "[1/2] Updating feeds"
  if [[ "$force" -eq 1 ]]; then
    ./scripts/feeds update -f "${update_args[@]}"
  else
    ./scripts/feeds update "${update_args[@]}"
  fi
else
  echo "[1/2] Skipping feeds update (--install-only)"
fi

if [[ "$do_install" -eq 1 ]]; then
  echo "[2/2] Installing feed packages"
  ./scripts/feeds install "${install_args[@]}"
else
  echo "[2/2] Skipping feeds install (--update-only)"
fi

