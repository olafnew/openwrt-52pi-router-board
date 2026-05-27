# OLED Support

The production router OLED currently works correctly and is the source of truth for the first public build.

## Current Known-Good Runtime State

From the live router:

| Setting | Value |
|---|---|
| UCI section | `oled.oled` |
| Enabled | `1` |
| I2C device | `i2c-1` |
| Path | `/dev/i2c-1` |
| Address | `0x3C` |
| Display type | `ssd1306` |
| Network source | `eth1` |
| Refresh time | `60` |
| Displayed fields | date/time, network speed, LAN IP, CPU frequency, CPU temperature |

The current router has `/dev/i2c-0 -> /dev/i2c-1` created at boot because the OLED binary expects the older path.

## Required Boot Handling

A small init script must create the symlink after `/dev/i2c-1` appears:

```sh
[ ! -e /dev/i2c-0 ] && [ -e /dev/i2c-1 ] && ln -s /dev/i2c-1 /dev/i2c-0
```

The March build used `/etc/init.d/oled-i2c-fix` with `START=95`, then restarted OLED after the symlink was present.

## Known Typo To Fix In New Firmware

The production router's `/etc/init.d/oled` has `START=1OO` with letter `O`, not zero. It still works in practice because of service ordering and the later I2C fix, but the new firmware should fix this to `START=100` and validate on the spare board.

## Upstream Lineage

OLED support comes from NateLol's OpenWrt OLED package/feed used by the 52Pi board ecosystem:

- https://github.com/NateLol/natelol
- https://github.com/NateLol/luci-app-oled

## Test Checklist

- OLED appears after first boot without manual SSH intervention.
- LuCI OLED settings page opens.
- `/dev/i2c-1` exists.
- `/dev/i2c-0` symlink exists and points to `/dev/i2c-1`.
- OLED survives `/etc/init.d/oled restart`.
- OLED still works after reboot.
- Network speed uses the actual WAN interface name for the profile under test.
