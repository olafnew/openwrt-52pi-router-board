# Building Firmware

Builds run on the Debian VM.

```sh
cd /mnt/synology-development/Software/OpenWRT/openwrt-52pi-router-board
```

The scripts default to the existing clean OpenWrt tree:

```sh
OPENWRT_DIR=/home/olafnew/build/src/openwrt-25.12.4
```

## First Dry Runs

Generate and verify `.config` without compiling:

```sh
CONFIG_ONLY=1 bash scripts/build-performance.sh
CONFIG_ONLY=1 bash scripts/build-full-vpn.sh
```

The dry runs also apply source-tree preparation:

- OpenWrt stable feeds plus pinned custom feeds.
- Realtek `r8168` package metadata patched to `8.056.02`.
- Raspberry Pi boot `config.txt` copied from `patches/bcm27xx/config.txt`.
- bcm2711 kernel timer fragment appended for `CONFIG_HZ_1000`.
- files overlay copied from `files/common` and profile-specific overlay directory.

## First Test Image IP

The first spare-board builds default to:

```sh
LAN_IP=192.168.1.254
```

The build script injects a first-boot UCI script that sets:

- `network.lan.ipaddr`
- DHCP option `42,<router-ip>` so clients can use router chrony as NTP

For later public/release builds, override this explicitly:

```sh
LAN_IP=192.168.1.1 bash scripts/build-performance.sh
```

Or skip the generated LAN-IP override:

```sh
LAN_IP= bash scripts/build-performance.sh
```

## Real Images

```sh
bash scripts/build-performance.sh
bash scripts/build-full-vpn.sh
```

Artifacts are copied into:

```text
releases/<UTC timestamp>-<profile>/
```

The `releases/` contents are intentionally ignored by git. Publish tested firmware through GitHub Releases, not normal repository commits.
