# OpenWrt for 52Pi Router Board for Raspberry Pi CM4/CM5

A maintained OpenWrt build project for the 52Pi Router Board family based on Raspberry Pi Compute Module 4/5 hardware.

This repository is intended to make a reproducible, documented, modern firmware for this board: fast Ethernet, working OLED, sane diagnostics, and an optional DPI/censorship-bypass profile using AmneziaWG and Podkop.

## What This Build Is For

| Goal | What this project provides |
|---|---|
| Stable base | Tracks the latest stable OpenWrt release, not random snapshots. |
| Real router performance | 1000 Hz kernel timer target, BBR, packet steering, IRQ tuning, SQM/autorate readiness, and honest Realtek r8168 driver policy. |
| Working board features | OLED support for the board's SSD1306 display, including LuCI integration and boot-time I2C handling. |
| Practical diagnostics | Includes tools that are normally missing during real troubleshooting: tcpdump, fping, dig, jq, ip-full/tc-full, conntrack, ethtool, iperf3, htop/btop, lsof, strace, and related helpers. |
| Two firmware profiles | Performance-only firmware and a full AmneziaWG + Podkop firmware for censorship-bypass routing. |
| Reproducible release process | Build scripts, patches, profile configs, source inventory, and hardware test checklist. |
| Documented hardware limits | The board's Realtek RTL8168E/RTL8111E Ethernet path does not provide functional RSS/multi-queue acceleration. |

## Important Realtek RSS Limitation

This board should not be advertised as having working Realtek RSS acceleration.

The current production router uses a Realtek `r8168 8.056.02-RSS` compiled driver, but the actual hardware exposes only one RX queue and one TX queue. That means traffic cannot be spread across CPU cores by RSS on this board revision.

Observed on the running router:

| Runtime item | Observed value |
|---|---|
| Ethernet chip | `RTL8168E/8111E` |
| RX queues | `1` |
| TX queues | `1` |
| Interrupts | `eth1-0` only |
| `EnableRss` | `0x0` |
| `HwSuppNumRxQueues` | `0x1` |
| `HwSuppNumTxQueues` | `0x1` |

So this project will keep the Realtek driver work needed for stable Ethernet, but it will not claim RSS as a working performance feature unless a different board/NIC revision proves multiple hardware queues. See [docs/realtek-driver.md](docs/realtek-driver.md) for the full driver audit.

## Firmware Profiles

| Profile | Purpose |
|---|---|
| `performance` | Board support, OLED, Realtek/r8168, kernel/network tuning, SQM, diagnostics, and general router performance packages. |
| `full-vpn` | Everything in `performance`, plus AmneziaWG, Podkop, sing-box, and the packages needed for policy routing / DPI bypass setups. |

## Current Build Policy

The public project tracks the latest stable OpenWrt series. As of 2026-05-28, the current stable OpenWrt release is `25.12.4`.

The old March build used `v25.12.0-rc5`; it remains archived as reference material, not as the future baseline.

## Hardware Target

- 52Pi Router Board for Raspberry Pi Compute Module 4 / Compute Module 5
- Broadcom BCM27xx family target in OpenWrt
- Realtek RTL8111/RTL8168 external Ethernet path; current RTL8168E/RTL8111E boards expose one RX/TX queue, so RSS is a documented hardware limitation
- SSD1306-compatible I2C OLED display
- Optional PoE HAT / RTC investigation remains documented separately

## Known-Good Features From The Running Router

The current production router is treated as source of truth until the new build is validated on the second board.

- Root filesystem layout: 128 MB boot partition and 2048 MB root partition.
- OLED service is known-good on the production router.
- OLED currently uses `/dev/i2c-1`, plus a boot-time `/dev/i2c-0 -> /dev/i2c-1` compatibility symlink.
- OLED displays date/time, network speed, LAN IP, CPU frequency, and CPU temperature.
- WAN network speed source is currently `eth1`.
- The production router has extra operational fixes that may not exist in the old March script, so router export/audit is part of the release process.

## Credits

This project builds on work from:

- [OpenWrt](https://openwrt.org/)
- [52Pi](https://52pi.com/)
- [Jeff Geerling](https://www.jeffgeerling.com/) and his Raspberry Pi router research
- [NateLol luci-app-oled / natelol feed](https://github.com/NateLol/natelol) for OLED support used by the 52Pi board ecosystem
- [AmneziaWG](https://github.com/amnezia-vpn/)
- [Podkop](https://github.com/itdoginfo/podkop)

## Donations

If this saves you time and you want to say thanks:

- Ethereum: `0xF10eC1ffd26c84e21B9ed075DEFE8bD4455De12a`
- Bitcoin: `bc1quuwyx92ye3du37lvnecgy8yghd2ertnehan62s`

GitHub also supports repository funding links through `.github/FUNDING.yml`, but raw crypto wallet addresses are kept here because GitHub funding metadata expects links.

## Repository Status

Initial public repository structure is being prepared. Build scripts and patches will be added after the current production router state is exported and compared against the March reference build.

Do not flash anything from this repository until a tagged release explicitly says it was built and tested on the spare physical board.
