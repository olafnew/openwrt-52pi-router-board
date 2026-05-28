# Debian VM Build Machine

This VM is the build worker for the 52Pi/OpenWrt project. It is not the source of truth for project files.

## Access

From Codex Desktop / Windows host:

```text
ssh debian-vm
```

Current observed VM state:

| Item | Value |
|---|---|
| OS | Debian 13 / trixie |
| Kernel | `6.12.90+deb13.1-amd64` |
| User | `olafnew` |
| CPU threads | 22 |
| RAM | 15 GiB |
| Root disk | 74 GiB |
| Codex CLI | `0.134.0` |

`olafnew` has passwordless sudo on this VM because it is a disposable build worker.

## Synology Project Mount

The Synology `Development` share is mounted persistently:

```text
//192.168.1.2/Development -> /mnt/synology-development
```

Credentials are stored on the VM only:

```text
/etc/samba/credentials/synology-development
```

The repository path on the VM is a symlink to the NAS-backed repo:

```text
/home/olafnew/openwrt-52pi-router-board
  -> /mnt/synology-development/Software/OpenWRT/openwrt-52pi-router-board
```

This means repo edits, docs, scripts, release metadata, and build recipes are written directly to the NAS-backed source-of-truth location. If the VM dies or corrupts its local disk, the maintained repo survives on Synology and GitHub.

## Build Storage Policy

Do not build OpenWrt directly on the CIFS mount. OpenWrt builds should run on the VM local ext4 disk for speed and filesystem semantics.

Recommended model:

| Path | Role |
|---|---|
| `/home/olafnew/openwrt-52pi-router-board` | NAS-backed source repo |
| `/home/olafnew/openwrt-legacy-rc5` | symlink to archived March rc5 OpenWrt tree, reference only |
| `/home/olafnew/build/src/openwrt-25.12.4` | clean local OpenWrt 25.12.4 source tree |
| `/home/olafnew/build/cache/dl` | reusable OpenWrt download cache, symlinked as `dl/` in the clean tree |
| `/home/olafnew/build/artifacts` | temporary local staging area for build outputs |
| repo `releases/` or GitHub Releases | curated copied artifacts only |

The local build tree is disposable. Build scripts must be reproducible from the NAS/GitHub repo.

## Current Legacy OpenWrt Tree

Legacy tree:

```text
/home/olafnew/build/legacy/openwrt-25.12.0-rc5-legacy-20260528
/home/olafnew/openwrt-legacy-rc5 -> /home/olafnew/build/legacy/openwrt-25.12.0-rc5-legacy-20260528
```

Observed state:

```text
v25.12.0-rc5-dirty
M  feeds.conf.default
 M target/linux/bcm27xx/bcm2711/config-6.12
MM target/linux/bcm27xx/image/config.txt
?? package/kernel/r8168-8.056.02-rss/
```

Size breakdown:

| Directory | Approx size |
|---|---:|
| `build_dir` | 19 GiB |
| `staging_dir` | 2.8 GiB |
| `dl` | 2.0 GiB |
| `tmp` | 1.7 GiB |
| `bin` | 219 MiB |
| total tree | 26 GiB |

Treat this as legacy reference material, not the baseline for new builds. The new build system should start from latest stable OpenWrt and reproduce required changes from documented patches/scripts.

## Current Clean OpenWrt Tree

Prepared on 2026-05-28:

```text
/home/olafnew/build/src/openwrt-25.12.4
```

Observed state:

| Item | Value |
|---|---|
| OpenWrt tag | `v25.12.4` |
| OpenWrt commit | `ba915c2` |
| `packages` feed | `f91b06b` |
| `luci` feed | `e9ebca75` |
| `routing` feed | `b2097c8` |
| `telephony` feed | `2618106` |
| `video` feed | `094bf58` |

Smoke test completed:

```text
CONFIG_TARGET_bcm27xx=y
CONFIG_TARGET_bcm27xx_bcm2711=y
CONFIG_TARGET_bcm27xx_bcm2711_DEVICE_rpi-4=y
make defconfig
```

`make defconfig` completed successfully. The warnings seen during feed install/defconfig were generic missing optional feed dependency warnings, not target-blocking errors.

## Cleanup Performed

On 2026-05-28:

- installed `cifs-utils` and `smbclient`
- configured persistent Synology CIFS mount
- created VM repo symlink
- enabled passwordless sudo for `olafnew`
- removed auto-removable old Debian kernels:
  - `linux-image-6.12.63+deb13-amd64`
  - `linux-image-6.12.69+deb13-amd64`
  - `linux-image-6.12.73+deb13-amd64`
- cleaned apt cache
- archived selected legacy build-machine state to:
  - `/mnt/synology-development/Software/OpenWRT/_reference-build-machine/20260528-legacy-openwrt-rc5`
- moved `/home/olafnew/openwrt` to the legacy path above
- moved old feed/reference directories and helper scripts to:
  - `/home/olafnew/build/legacy/supporting-refs-20260528`
- left compatibility symlinks in `/home/olafnew` for the old feed/reference paths
- installed missing Debian/OpenWrt build prerequisites from the current OpenWrt build-system guide
- cloned OpenWrt `v25.12.4` into the clean source path
- updated and installed OpenWrt release-pinned feeds
- ran the BCM2711/RPi4 `make defconfig` smoke test

No OpenWrt build tree files were deleted. The legacy tree was renamed/moved only.

## Remaining Cleanup Candidates

These should not be deleted until the new firmware can reproduce the required behavior and the archived material has been reviewed:

- `/home/olafnew/build/legacy/openwrt-25.12.0-rc5-legacy-20260528/build_dir`
- `/home/olafnew/build/legacy/openwrt-25.12.0-rc5-legacy-20260528/staging_dir`
- `/home/olafnew/build/legacy/openwrt-25.12.0-rc5-legacy-20260528/tmp`

These directories are large generated build outputs. They are useful while reconciling the March build, but should eventually be replaced by reproducible scripts plus curated release artifacts.
