# Scripts

This directory will contain build, inspection, release, and verification scripts.

Planned scripts:

- `inspect-router.sh` - collect redacted source-of-truth data from a running router.
- `prepare-build-tree.sh` - clone/update OpenWrt stable source and feeds.
- `build-performance.sh` - build the performance firmware profile.
- `build-full-vpn.sh` - build the full AmneziaWG + Podkop firmware profile.
- `collect-artifacts.sh` - copy build outputs and manifests into a release staging folder.

Scripts are intentionally not implemented in this first skeleton commit.
