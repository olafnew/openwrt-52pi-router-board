#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat >&2 <<'USAGE'
Usage: packages-to-config.sh <package-list>...

Converts newline-delimited OpenWrt package names into CONFIG_PACKAGE_* lines.
The conversion is intentionally conservative: runtime libraries and core base
packages are left to OpenWrt dependency resolution, while user-facing packages,
kmods, LuCI apps, and diagnostic tools are selected explicitly.
USAGE
}

[ "$#" -gt 0 ] || { usage; exit 2; }

emit_package() {
	local pkg="$1"

	case "$pkg" in
		''|\#*) return 0 ;;
		base-files|busybox|kernel|libc|dropbear|firewall4|fstools|fwtool|logd|mtd|netifd|procd|procd-seccomp|procd-ujail|ubox|ubus|ubusd|uci|uclient-fetch|urandom-seed|usign|openwrt-keyring|apk-mbedtls)
			return 0
			;;
		lib*|jansson*|json-glib*|oniguruma*|zlib|terminfo|getrandom|rpcd|rpcd-mod-*|ucode|ucode-mod-*|jshn|jsonfilter)
			return 0
			;;
		dnsmasq)
			printf '# CONFIG_PACKAGE_dnsmasq is not set\n'
			return 0
			;;
		ip-tiny)
			pkg="ip-full"
			;;
		tc-tiny)
			pkg="tc-full"
			;;
		kmod-r8168-8.056.02-rss)
			pkg="kmod-r8168-rss"
			;;
	esac

	printf 'CONFIG_PACKAGE_%s=y\n' "$pkg"
}

for list in "$@"; do
	[ -f "$list" ] || { echo "Package list not found: $list" >&2; exit 1; }
	while IFS= read -r raw || [ -n "$raw" ]; do
		raw=${raw%$'\r'}
		raw=${raw%%#*}
		raw=$(printf '%s' "$raw" | awk '{$1=$1; print}')
		emit_package "$raw"
	done < "$list"
done | awk '!seen[$0]++'
