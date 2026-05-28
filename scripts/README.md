# Scripts

Build scripts are intended to run on the Debian build VM.

Default paths:

```sh
OPENWRT_DIR=/home/olafnew/build/src/openwrt-25.12.4
REPO_ROOT=/mnt/synology-development/Software/OpenWRT/openwrt-52pi-router-board
```

## Commands

Prepare feeds and source-tree patches only:

```sh
cd /mnt/synology-development/Software/OpenWRT/openwrt-52pi-router-board
bash scripts/prepare-build-tree.sh
```

Generate and verify the Performance profile without compiling:

```sh
CONFIG_ONLY=1 bash scripts/build-performance.sh
```

Generate and verify the Full VPN/Podkop profile without compiling:

```sh
CONFIG_ONLY=1 bash scripts/build-full-vpn.sh
```

Build images:

```sh
bash scripts/build-performance.sh
bash scripts/build-full-vpn.sh
```

## Important Defaults

The first spare-board test images default to:

```sh
LAN_IP=192.168.1.254
```

This avoids conflicting with the production router at `192.168.1.1`.

Override for later public/release builds:

```sh
LAN_IP=192.168.1.1 bash scripts/build-performance.sh
```

Or leave the variable empty to skip injecting a LAN-IP first-boot script:

```sh
LAN_IP= bash scripts/build-performance.sh
```

## Script Map

- `build-common.sh` - shared implementation used by all build wrappers.
- `prepare-build-tree.sh` - prepares feeds, Realtek r8168 metadata, boot config, and 1000 Hz kernel timer patch.
- `build-performance.sh` - builds the performance firmware profile.
- `build-full-vpn.sh` - builds the full AmneziaWG + Podkop firmware profile.
- `collect-artifacts.sh` - copies images, manifests, buildinfo, config, feeds, and generated checksums into `releases/`.
- `packages-to-config.sh` - converts package-name lists into conservative `.config` selections.
