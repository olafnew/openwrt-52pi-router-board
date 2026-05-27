# Repository Organization Design

## Goal

Create a public-safe OpenWrt firmware repository for the 52Pi Router Board while preserving old build material and private data outside git.

## Scope

This first step creates the repository skeleton, documentation map, archive inventory, and guardrails. It does not implement final build scripts and does not modify the router, VPS, or Debian build server.

## Architecture

The NAS path `\\192.168.1.2\Development\Software\OpenWRT` is the local working root. The public git repository is only `openwrt-52pi-router-board/`.

Large and stale material is kept in sibling folders:

- `_reference-march-rc5-build/`
- `_reference-current-router/`
- `_archive-old-builds/`
- `_archive-large/`
- `_archive-unrelated/`
- `_private-sensitive/`

This makes it possible to publish the repo without accidentally committing VM images, firmware images, passwords, packet captures, or old failed build trees.

## Decisions

- Track latest stable OpenWrt as the future baseline.
- Treat the production router as source of truth until the spare board validates a replacement image.
- Keep the March rc5 build as reference only.
- Preserve OLED known-good behavior, but fix the `START=1OO` typo in the new firmware and test it on spare hardware.
- Keep donation wallet addresses in README text rather than `.github/FUNDING.yml`, because GitHub funding metadata expects URLs.

## Validation

The initial skeleton is valid when:

- the repo folder has publishable docs and no private files;
- archives remain outside the repo;
- `.gitignore` blocks common build outputs and secrets;
- git status shows only intentional initial files.
