# Scripts

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

