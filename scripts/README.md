# Scripts

This directory contains helper scripts intended to make feed syncing and
configuration/profile-based builds more repeatable.

## `update-passwall.sh`

Updates the Passwall feeds and optionally installs all packages from them.

### What it does

- Runs `./scripts/feeds update passwall_packages passwall_luci` (use `--force` to pass `-f`)
- Optionally runs:
  - `./scripts/feeds install -a -p passwall_packages`
  - `./scripts/feeds install -a -p passwall_luci`
- Optionally runs `make defconfig`
- Prints the current revisions for both feeds

### Usage

```sh
scripts/update-passwall.sh [--force] [--no-install] [--defconfig]
```

### Examples

Update to the latest feed state and install packages:

```sh
scripts/update-passwall.sh
```

Force-update feeds (discard local changes under `feeds/passwall_*` if needed) and run `make defconfig`:

```sh
scripts/update-passwall.sh --force --defconfig
```

Update only (skip install):

```sh
scripts/update-passwall.sh --no-install
```

## `sync-feeds.sh`

Synchronizes feeds using `./scripts/feeds update` and `./scripts/feeds install`.

### What it does

- By default: `./scripts/feeds update -a` and `./scripts/feeds install -a`
- When feed names are provided: updates those feeds and installs packages from those feeds

### Usage

```sh
scripts/sync-feeds.sh [--force] [--update-only|--install-only] [feedname...]
```

### Examples

Update and install all feeds:

```sh
scripts/sync-feeds.sh
```

Update only:

```sh
scripts/sync-feeds.sh --update-only
```

Sync a subset of feeds:

```sh
scripts/sync-feeds.sh packages luci
```

## `apply-profile.sh`

Applies a `diffconfig` profile from `profiles/` to generate a full `.config`,
then runs `make defconfig`.

### What it does

- Optionally syncs all feeds first (`--sync-all-feeds`)
- Optionally updates Passwall feeds first (default)
- Generates `.config` from `profiles/<name>.diffconfig`
- Runs `make defconfig`
- Prints Passwall feed revisions for traceability

### Usage

```sh
scripts/apply-profile.sh <profile-name> [options]
```

### Examples

Apply profile and update Passwall feeds first:

```sh
scripts/apply-profile.sh x86_64-passwall-docker
```

Apply profile after syncing all feeds (update + install):

```sh
scripts/apply-profile.sh x86_64-passwall-docker --sync-all-feeds
```

