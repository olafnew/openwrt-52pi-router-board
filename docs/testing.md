# Hardware Testing Plan

The spare board is the test target. The production router at `192.168.1.1` should not be interrupted during firmware development.

## First Boot Test

- Flash image to spare board storage.
- Connect board to isolated test LAN or temporary port.
- Assign a temporary static DHCP lease on the production router.
- SSH into the spare board.
- Save `dmesg`, `logread`, package list, network interface list, and partition layout.

## Board Feature Tests

- WAN Ethernet link comes up at expected speed.
- LAN Ethernet works.
- OLED works after boot and after service restart.
- LuCI loads.
- SSH works.
- DNS/DHCP works in the selected test topology.

## Performance Tests

- Baseline iperf3 LAN/WAN path test.
- SQM/autorate smoke test.
- CPU load under download pressure.
- Packet loss / latency under bulk traffic.

## Full VPN Profile Tests

- AmneziaWG module loads.
- AmneziaWG interface can be configured.
- Podkop LuCI page opens.
- sing-box starts with a known-good test config.
- DNS behavior is validated before any production config is migrated.
