# Realtek Driver Policy

Verified on 2026-05-28.

## Current Production Router

The running router loads:

```text
r8168
```

`ethtool` is not installed on the production router, so detailed driver/link metadata cannot currently be queried there. This is one of the reasons `ethtool` is included in `profiles/common-extra-tools.packages.txt`.

## OpenWrt 25.12.4 Baseline

The clean `v25.12.4` source tree currently has:

```text
package/kernel/r8168  PKG_VERSION:=8.055.00
package/kernel/r8125  PKG_VERSION:=9.016.01
package/kernel/r8126  PKG_VERSION:=10.016.00
package/kernel/r8127  PKG_VERSION:=11.015.00
```

The stock `r8168` package already provides two variants:

- `kmod-r8168`
- `kmod-r8168-rss`

The `rss` variant enables:

```text
ENABLE_MULTIPLE_TX_QUEUE=y
ENABLE_RSS_SUPPORT=y
```

## Latest r8168 Status

The latest known OpenWrt-maintained r8168 release is:

```text
r8168 8.056.02
```

Evidence:

- OpenWrt `rtl8168` release repository marks `8.056.02` as latest.
- OpenWrt main branch `package/kernel/r8168/Makefile` already uses `PKG_VERSION:=8.056.02` and hash `38c48129c41d1dc38681cb83e87c70bda12873384899d94ecc26bb79903829ce`.
- Gentoo and Arch Linux packaging also track `8.056.02`; current Arch rebuilds are package rebuilds around the same upstream version, not a newer upstream release.

No credible newer `8.057.*` upstream r8168 release was found during the 2026-05-28 check.

## Build Decision

Do not keep the old custom package name:

```text
kmod-r8168-8.056.02-rss
```

Instead, use the official OpenWrt package shape and backport/update it to `8.056.02` in our build:

```text
kmod-r8168-rss
```

This is a deliberate package-name deviation from the current production router. It preserves the actual technical behavior we care about:

- Realtek vendor r8168 driver.
- Version `8.056.02`.
- RSS enabled.
- multiple TX queues enabled.

The change should be validated on the spare board before production use.

## r8125

OpenWrt `25.12.4` already has `r8125 9.016.01`, and the OpenWrt `rtl8125` release repository also shows `9.016.01` as latest. The current board is using r8168, so r8125 is not part of the first target unless a later board revision or CM5 carrier test shows a 2.5G Realtek NIC.

