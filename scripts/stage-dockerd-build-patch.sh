#!/usr/bin/env bash
set -euo pipefail

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$TOPDIR"

source_patch="$TOPDIR/patches/dockerd/100-skip-host-nested-binaries.patch"
package_dir="$TOPDIR/feeds/packages/utils/dockerd"
target_patch="$package_dir/patches/999-openwrt-skip-host-nested-binaries.patch"

if [[ ! -f "$source_patch" ]]; then
  echo "Error: dockerd compatibility patch is missing: $source_patch" >&2
  exit 1
fi

if [[ ! -f "$package_dir/Makefile" ]]; then
  echo "Error: dockerd package is missing. Run ./scripts/feeds update packages first." >&2
  exit 1
fi

if ! grep -qx 'PKG_NAME:=dockerd' "$package_dir/Makefile"; then
  echo "Error: unexpected dockerd package Makefile: $package_dir/Makefile" >&2
  exit 1
fi

if [[ -f "$target_patch" ]] && cmp -s "$source_patch" "$target_patch"; then
  echo "Dockerd compatibility patch already staged"
  exit 0
fi

install -Dm0644 "$source_patch" "$target_patch"
echo "Staged dockerd compatibility patch"
