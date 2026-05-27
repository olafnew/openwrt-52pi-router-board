# Build Policy

## Baseline

The project tracks the latest stable OpenWrt release.

Verified on 2026-05-28:

- Current stable series: OpenWrt 25.12
- Current stable release: OpenWrt 25.12.4
- Official downloads path: https://downloads.openwrt.org/releases/25.12.4/

The previous March firmware was based on `v25.12.0-rc5`. It is preserved as reference material only.

## Release Types

| Release type | Meaning |
|---|---|
| Test build | Built for the spare board only. Not recommended for production. |
| Candidate | Built from documented source state and manually checked on spare board. |
| Stable project release | Candidate that survived hardware validation and normal network testing. |

## Build Host

Builds are expected to run on the Debian VM build server:

- SSH alias from Windows/Codex Desktop: `debian-vm`
- OpenWrt build tree currently inspected at: `/home/olafnew/openwrt`
- The existing tree is useful but stale; do not treat it as the only source of truth.

## Version Rule

Use latest stable OpenWrt and latest compatible package/feed state, unless a package must be pinned for reproducibility or because upstream broke compatibility.

All pins must be documented with:

- upstream URL
- commit/tag/version
- reason for pinning
- date verified
