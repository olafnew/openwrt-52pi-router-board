# Next Build Decisions

Before the first real firmware image, these decisions should be explicit.

## First Images To Build

First build run should produce both supported images:

1. Performance profile.
2. Full VPN profile with AmneziaWG and Podkop.

Reason: the performance image validates board support, Realtek Ethernet, OLED, kernel tick rate, partitioning, LuCI, diagnostics, SQM, and base services. The Full VPN/Podkop image then proves that the production censorship-bypass stack can be reproduced from the same build.

The Full VPN/Podkop image must closely mimic the installed package set on the running production router. The source package-name list is:

```text
profiles/full-vpn-podkop.production-packages.txt
```

That list is copied from the production-router snapshot:

```text
_reference-current-router/20260528-030422/packages/installed-package-names.txt
```

When converting it into OpenWrt `.config` selections, dependencies may be supplied automatically by the build system, and some package names may need adjustment if OpenWrt `25.12.4` renamed or replaced them. Any deviation from the live package list must be documented.

## First Hardware Target

Recommended first target:

```text
bcm27xx/bcm2711 rpi-4
```

This matches the current working CM4 router. CM5 support should be treated as a separate target/research item because it may require different Raspberry Pi SoC support and testing.

## Spare Board Network Plan

For first flash testing, use a known-free temporary static address. The test board must not take `192.168.1.1`.

Proposed temporary address:

```text
192.168.1.254
```

No MAC-based DHCP reservation is required for the first test plan. If later we want deterministic DHCP instead of a static test address, capture the spare board MAC after first boot.

## Features To Reproduce First

Minimum first-pass reproduction list:

- 128 MiB boot partition and 2048 MiB root partition.
- Realtek r8168 driver package.
- 1000 Hz kernel tick.
- boot config: I2C enabled, 1.8 GHz overclock, low GPU memory, no audio.
- OLED package, LuCI integration, init scripts, health/restart behavior.
- fixed OLED init typo from the old router: `START=100`, then hardware-test it.
- Chrony enabled, sysntpd disabled.
- SQM and cake-autorate support.
- diagnostic packages listed in `docs/packages.md`.
- Full VPN/Podkop profile package source matching `profiles/full-vpn-podkop.production-packages.txt`.
- IPv6-disabled policy matching the current build.

## Still Needed From User

- Approval before deleting any generated legacy build directories from the VM.
- Approval before flashing the spare board. User will flash only after the first firmware images are built.
