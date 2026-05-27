# Source Inventory

Local working root:

`\\192.168.1.2\Development\Software\OpenWRT`

## Publishable Repository

`openwrt-52pi-router-board/`

This is the maintained Git repository that should eventually be pushed to `github.com/olafnew/openwrt-52pi-router-board`.

## Reference Material Outside Git

| Folder | Purpose |
|---|---|
| `_reference-march-rc5-build/` | Old March build scripts, notes, driver tarball, and firmware manifest/images. |
| `_reference-current-router/` | Reserved for redacted exports from the live router at `192.168.1.1`. |
| `_archive-old-builds/` | Previous build attempts, rc4/snapshot/freezing variants, loose VirtualBoxShared leftovers. |
| `_archive-large/` | Large VM images and build backups. Kept outside git. |
| `_archive-unrelated/` | Files that were present in the old folder but do not belong in this firmware repo. |
| `_private-sensitive/` | Passwords and other private material. Never commit. |

## March Reference Build

Key files:

- `_reference-march-rc5-build/scripts-final/Final scripts (3 march).zip`
- `_reference-march-rc5-build/scripts-final/PODKOP+AmneziaWG_openwrt_v25_FULL (LATEST 23Feb).sh`
- `_reference-march-rc5-build/scripts-final/r8168-8.056.02.tar.bz2`
- `_reference-march-rc5-build/firmware-bcm2711-current/bcm2711/openwrt-bcm27xx-bcm2711-rpi-4.manifest`

## Production Router Source Of Truth

The live router at `192.168.1.1` has changes that may not exist in the March script. Before producing a public build, export and redact:

- installed package list
- `/etc/config/oled`
- `/etc/init.d/oled`
- `/etc/init.d/oled-i2c-fix`
- relevant `/boot/config.txt` fragments
- kernel config deltas
- partition layout
- sysctl and network tuning
- SQM/autorate configuration
- installed custom packages and versions

Do not export private keys, passwords, tokens, personal Podkop domain lists, or full VPN configs into git.
