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

## Performance Profile

Performance profile includes board support, OLED, Realtek Ethernet work, kernel/network tuning, SQM, and diagnostics.

## Full VPN Profile

Full VPN profile includes all performance packages plus:

- AmneziaWG kernel/userspace/LuCI integration
- Podkop and LuCI app
- sing-box
- DNS/routing helpers needed by Podkop-based policy routing

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
