# Firmware Profiles

This directory will contain reproducible OpenWrt profile config fragments.

Planned profiles:

- `performance.config` - base high-performance board firmware.
- `full-vpn-podkop.config` - performance profile plus AmneziaWG, Podkop, sing-box, and routing/DNS helpers.

The first build run should produce both profiles.

## Common Extra Tools

`common-extra-tools.packages.txt` is mandatory for both profiles.

It intentionally includes tools that are missing from the current production router but were repeatedly needed during troubleshooting. The live-router package list remains a baseline snapshot, not a ceiling.

## Production Package Source

`full-vpn-podkop.production-packages.txt` is the package-name list captured from the running production router on 2026-05-28.

Use it as the source of truth for the Full VPN/Podkop image package selection. During conversion to an OpenWrt `.config`, the build system may provide dependencies automatically, and `25.12.4` package naming may require small documented adjustments.

Do not treat this file as a private secret; it contains package names only. Do not add private router configs, Podkop personal lists, VPN keys, or endpoints to this directory.
