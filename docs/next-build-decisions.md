# Next Build Decisions

Before the first real firmware image, these decisions should be explicit.

## First Image To Build

Recommended order:

1. Performance profile.
2. Full VPN profile with AmneziaWG and Podkop.

Reason: the performance image validates board support, Realtek Ethernet, OLED, kernel tick rate, partitioning, LuCI, diagnostics, SQM, and base services before adding the more fragile censorship-bypass stack.

## First Hardware Target

Recommended first target:

```text
bcm27xx/bcm2711 rpi-4
```

This matches the current working CM4 router. CM5 support should be treated as a separate target/research item because it may require different Raspberry Pi SoC support and testing.

## Spare Board Network Plan

For first flash testing, use a temporary static DHCP reservation on the production router. The test board should not take `192.168.1.1`.

Proposed temporary address:

```text
192.168.1.250
```

The exact MAC address must be taken from the spare board before creating the reservation.

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
- IPv6-disabled policy matching the current build.

## Still Needed From User

- Spare board MAC address once it is connected.
- Confirmation that the first generated image should be the Performance profile.
- Approval before deleting any generated legacy build directories from the VM.
- Approval before flashing the spare board.

