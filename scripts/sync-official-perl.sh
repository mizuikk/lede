#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-official-perl.sh

Synchronize the official OpenWrt perl tree into feeds/packages/lang/perl.

This script tracks the latest state of:
  https://github.com/openwrt/packages
  branch: openwrt-25.12

It updates a local cache under .cache/openwrt-packages, refreshes the
working-tree feeds/packages/lang/perl tree used by the build, then rebuilds
the packages feed index so the new Perl metadata is visible immediately.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TOPDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$TOPDIR"

upstream_url="https://github.com/openwrt/packages"
upstream_branch="openwrt-25.12"
cache_dir="$TOPDIR/.cache/openwrt-packages"
src_dir="$cache_dir/lang/perl"
dst_dir="$TOPDIR/feeds/packages/lang/perl"

mkdir -p "$TOPDIR/.cache"

if [[ ! -e "$TOPDIR/feeds/packages/.git" ]]; then
  echo "Error: feeds/packages is missing. Run ./scripts/feeds update packages first." >&2
  exit 1
fi

if [[ ! -x "$TOPDIR/scripts/feeds" ]]; then
  echo "Error: ./scripts/feeds not found or not executable." >&2
  exit 1
fi

if [[ ! -d "$cache_dir/.git" ]]; then
  git clone --depth 1 --branch "$upstream_branch" "$upstream_url" "$cache_dir"
else
  git -C "$cache_dir" remote set-url origin "$upstream_url"
  git -C "$cache_dir" fetch --depth 1 origin "$upstream_branch"
  git -C "$cache_dir" checkout -B "$upstream_branch" "origin/$upstream_branch"
  git -C "$cache_dir" clean -fd
fi

if [[ ! -f "$src_dir/Makefile" || ! -f "$src_dir/perlver.mk" ]]; then
  echo "Error: upstream perl source is incomplete: $src_dir" >&2
  exit 1
fi

mkdir -p "$(dirname "$dst_dir")"
mkdir -p "$dst_dir"
rsync -a --delete "$src_dir"/ "$dst_dir"/

if [[ ! -f "$dst_dir/Makefile" || ! -f "$dst_dir/perlver.mk" ]]; then
  echo "Error: synchronized perl tree is incomplete: $dst_dir" >&2
  exit 1
fi

revision="$(git -C "$cache_dir" rev-parse --short HEAD)"

# feeds/packages.tmp caches per-package dump output keyed largely by path and
# timestamps. rsync preserves upstream mtimes, so replacing lang/perl without
# invalidating that cache can leave the old Perl metadata in packages.index.
rm -rf "$TOPDIR/feeds/packages.tmp"
rm -f "$TOPDIR/feeds/packages.index" "$TOPDIR/feeds/packages.targetindex"

./scripts/feeds update -i packages

echo "Synchronized official perl:"
echo "  source=$upstream_url"
echo "  branch=$upstream_branch"
echo "  revision=$revision"
echo "  destination=feeds/packages/lang/perl"
echo "  packages_index=refreshed"
