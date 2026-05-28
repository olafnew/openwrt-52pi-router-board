# Current Production Router State

Snapshot captured: `20260528-030422`

Local reference snapshot, outside git:

`\\192.168.1.2\Development\Software\OpenWRT\_reference-current-router\20260528-030422`

Collection mode: read-only SSH command collection from `192.168.1.1`, followed by local redaction. Private keys, preshared keys, passwords, tokens, MAC addresses, and private domain values are not intended to be present in the reference snapshot or this repository.

## Platform

| Item | Current value |
|---|---|
| OpenWrt | `25.12.0-rc5 r32673-482ba7230a` |
| Target | `bcm27xx/bcm2711` |
| Architecture | `aarch64_cortex-a72` |
| Kernel | `6.12.71` |
| Package manager | `apk-tools 3.0.2` |
| Root filesystem | ext4 mounted on `/` |
| RAM | ~8 GB |
| Swap | none |

## Partition Layout

| Device | Size | Purpose |
|---|---:|---|
| `mmcblk0p1` | 128 MB | boot partition |
| `mmcblk0p2` | 2048 MB | root filesystem |

Build invariant to preserve:

```text
CONFIG_TARGET_KERNEL_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=2048
```

## Boot Configuration

The production router `/boot/config.txt` includes:

```text
dtoverlay=dwc2,dr_mode=host
dtparam=i2c1=on
dtparam=i2c_arm=on
arm_freq=1800
over_voltage=4
gpu_mem=16
dtoverlay=vc4-kms-v3d,noaudio
```

These should be kept as first-build defaults unless the spare-board test shows a regression.

## Network Shape

| Interface | Role |
|---|---|
| `eth0` | LAN bridge member |
| `br-lan` | LAN, `192.168.1.1/24` |
| `eth1` | external Ethernet / WAN |
| `AWG0` | outbound AmneziaWG censorship-bypass tunnel |
| `AWG1` | inbound AmneziaWG server profile for client devices |
| `ifb4eth1` | IFB device for ingress SQM/CAKE |

Important current routing facts:

- `network.globals.packet_steering='2'`
- static route to Technitium tunnel-local DNS: `10.8.1.254` via `AWG0`
- Podkop policy routing rule present: fwmark `0x100000/0x100000` lookup `podkop`
- WAN hardening applies to `eth1` through `/etc/sysctl.d/99-wan-hardening.conf`
- IPv6 is globally disabled for normal routing; virtual interface runtime flags still need validation during new-image testing

## OLED

The OLED state from the running router is the source of truth.

| Setting | Value |
|---|---|
| package | `luci-app-oled 1.0-r1` |
| enabled | yes |
| I2C device | `i2c-1` |
| path | `/dev/i2c-1` |
| address | `0x3C` |
| display type | `ssd1306` |
| LAN IP interface | `br-lan` |
| network speed source | `eth1` |
| refresh | `60` |

Current support scripts:

- `/etc/init.d/oled`
- `/etc/init.d/oled-i2c-fix`

Known current quirk:

```text
START=1OO
```

The production init script uses letter `O` instead of zero. The new firmware should fix this to `START=100`, but only validate that change on the spare board first. The current router still works because `oled-i2c-fix` runs at `START=95`, creates `/dev/i2c-0 -> /dev/i2c-1`, then restarts OLED.

## Time

Current service state:

| Service | State |
|---|---|
| `chronyd` | enabled |
| `sysntpd` | disabled |

This confirms the new build should use chrony and should not rely on OpenWrt `sysntpd`.

## SQM, Autorate, And AWG2 Shaping

Current service state:

| Service | State |
|---|---|
| `sqm` | enabled |
| `cake-autorate` | enabled |
| `awg2-health-monitor` | enabled |
| `awg2-shaper-publisher` | enabled |

Current static SQM UCI baseline:

```text
interface=eth1
qdisc=cake
script=piece_of_cake.qos
download=350000
upload=350000
overhead=44
```

Runtime CAKE rates are dynamic because `cake-autorate` is active. At capture time, observed qdiscs included:

```text
eth1      cake bandwidth 250Mbit
ifb4eth1  cake bandwidth ~425724Kbit
```

The router also publishes derived shaper rates to the VPS for the AWG2 return path. Current publisher guardrails from the live router:

```text
MIN_KBPS=100000
MAX_KBPS=450000
FALLBACK_KBPS=100000
SAFETY_PERCENT=90
RAISE_PERCENT_PER_STEP=101
```

The current public firmware should not ship production VPS keys or endpoints. It should either document this as an optional advanced integration or provide a template with placeholders.

## Installed Package Delta

The live router has 317 installed package names. The March rc5 manifest has 313.

Live packages that are not in the March manifest:

| Package | Version |
|---|---|
| `bash` | `5.3-r2` |
| `fping` | `5.3-r1` |
| `libpcap1` | `1.10.6-r1` |
| `tcpdump` | `4.99.6-r1` |

The live router also has corrected Podkop versions:

| Package | Live router | March manifest |
|---|---:|---:|
| `podkop` | `0.7.14-r1` | `0.22022026-r1` |
| `luci-app-podkop` | `0.7.14-r1` | `0.22022026-r1` |

## Custom Material To Preserve Or Convert To Templates

The router contains useful custom operational state that did not exist in the original public-skeleton repo:

- `cake-autorate` installed under `/root/cake-autorate`
- `/etc/init.d/cake-autorate`
- `/root/awg2-health-monitor.sh`
- `/root/awg2-shaper-publisher.sh`
- `/etc/init.d/awg2-health-monitor`
- `/etc/init.d/awg2-shaper-publisher`
- `/etc/init.d/cpu-governor`
- `/etc/sysctl.d/99-wan-hardening.conf`
- `/etc/sysctl.d/10-disable-ipv6.conf`
- `/etc/sysctl.d/11-conntrack-timeouts.conf`

These should be reviewed and converted into clean overlay files or optional documented extras. Do not publish private SSH keys, production endpoints, AWG private keys, or personal Podkop lists.
