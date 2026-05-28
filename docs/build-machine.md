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
| `/home/olafnew/openwrt` | legacy March rc5 OpenWrt tree, reference only |
| future `/home/olafnew/build/openwrt-*` | disposable local build trees |
| repo `releases/` or GitHub Releases | curated copied artifacts only |

The local build tree is disposable. Build scripts must be reproducible from the NAS/GitHub repo.

## Current Legacy OpenWrt Tree

Existing tree:

```text
/home/olafnew/openwrt
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

No OpenWrt build tree files were deleted.

## Remaining Cleanup Candidates

These should not be deleted until they are either archived to NAS or proven redundant:

- `/home/olafnew/openwrt`
- `/home/olafnew/amneziawg-feed`
- `/home/olafnew/amneziawg-openwrt-ref`
- `/home/olafnew/podkop-feed`
- `/home/olafnew/podkop-feed-old`
- `/home/olafnew/podkop-inspect`
- `/home/olafnew/combined-diffconfig.bak`
- `/home/olafnew/recreate_amneziawg_openwrt.sh`
- `/home/olafnew/patch_amneziawg_js.py`

Next cleanup step should be an archive/sync pass into the NAS reference area, then removal from the VM only after verification.
