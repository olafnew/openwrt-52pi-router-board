# Package Policy

## Core Diagnostic Packages

These packages should be available in the maintained build because they were repeatedly needed during real troubleshooting:

- `fping`
- `tcpdump`
- `conntrack-tools`
- `ethtool`
- `ip-full`
- `tc-full`
- `nftables-json` / full nftables helpers where available
- `bind-dig` or equivalent DNS tools
- `curl`
- `wget`
- `jq-full`
- `btop`
- `htop`
- `nload`
- `iftop` or maintained alternative
- `iperf3`
- `lsof`
- `strace`
- `rsync`
- `chrony`
- `luci-app-chrony`
- `sqm-scripts`
- `luci-app-sqm`
- `irqbalance`
- `luci-app-irqbalance`
- filesystem tools needed for eMMC/SD diagnostics and resizing

The build source of truth for these shared additions is:

```text
profiles/common-extra-tools.packages.txt
```

This file must be applied to both generated images:

- Performance
- Full VPN/Podkop

It intentionally contains packages that are not present on the current production router. The production router snapshot is the baseline for behavior; the common extra tools are an explicit improvement for maintainability and field diagnostics.

## Common Extra Tools Missing From Production Router

These are intentional additions relative to `profiles/full-vpn-podkop.production-packages.txt`:

| Package | Reason |
|---|---|
| `conntrack` | Inspect NAT/conntrack state without guessing from firewall counters. |
| `ethtool` | Inspect NIC driver, link speed, duplex, offloads, and ring/channel state. |
| `ip-full` | Replace `ip-tiny` limitations during routing, rules, and tunnel debugging. |
| `tc-full` | Replace `tc-tiny` limitations during CAKE/SQM/autorate debugging. |
| `drill` | Lightweight DNS query tool alongside `bind-dig`. |
| `wget-ssl` | Full HTTPS-capable wget; production only has lighter fetch tooling. |
| `htop` | Process inspection when `btop` is inconvenient or absent in recovery contexts. |
| `iftop` | Per-flow traffic visibility during saturation and tunnel tests. |
| `iperf3` | Controlled throughput testing. |
| `lsof` | Identify processes holding sockets/files. |
| `strace` | Diagnose stuck user-space processes and service startup failures. |
| `rsync` | Safer file synchronization for configs, logs, and artifacts. |
| `openssh-client` | Router-origin SSH diagnostics and controlled file transfer workflows. |
| `openssh-client-utils` | OpenSSH client helper utilities, including scp-style workflows. |
| `openssh-sftp-client` | SFTP client for controlled transfers. |
| `openssh-sftp-server` | SFTP server support when dropbear/scp behavior is not enough. |
| `mmc-utils` | eMMC/SD diagnostics for the CM4 board. |
| `block-mount` | Storage/block-device diagnostics and mount workflows. |
| `lsblk` | Human-readable block-device inventory. |

## Performance Profile

Performance profile includes board support, OLED, Realtek Ethernet work, kernel/network tuning, SQM, and diagnostics.

## Full VPN Profile

Full VPN profile includes all performance packages plus:

- AmneziaWG kernel/userspace/LuCI integration
- Podkop and LuCI app
- sing-box
- DNS/routing helpers needed by Podkop-based policy routing

## Realtek Ethernet Driver

The Realtek driver policy is documented in:

```text
docs/realtek-driver.md
```

Current decision:

- use `kmod-r8168-rss` for the first parity build
- backport/update OpenWrt's official r8168 package to `8.056.02`
- do not preserve the old custom package name `kmod-r8168-8.056.02-rss`
- do not advertise RSS as functional on this board; the current router exposes one RX queue and one TX queue

## Rule For Optional Packages

Prefer packages that materially help maintainability, diagnostics, or board functionality. Avoid turning the image into a general-purpose Linux distribution.

## Current Router Package Delta

The 2026-05-28 production-router snapshot has four packages beyond the March rc5 manifest:

- `bash`
- `fping`
- `libpcap1`
- `tcpdump`

The new build should include these intentionally. `fping` is required by the current autorate/health workflow, and `tcpdump`/`libpcap1` are essential diagnostics.

The current router still uses `ip-tiny` and `tc-tiny`; the target build should prefer `ip-full` and `tc-full` if image size remains acceptable.
