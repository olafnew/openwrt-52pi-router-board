#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

: "${OPENWRT_DIR:=/home/olafnew/build/src/openwrt-25.12.4}"
: "${JOBS:=$(nproc)}"
: "${LAN_IP:=192.168.1.254}"
: "${PODKOP_VERSION:=0.7.17}"
: "${R8168_VERSION:=8.056.02}"
: "${R8168_HASH:=38c48129c41d1dc38681cb83e87c70bda12873384899d94ecc26bb79903829ce}"
: "${CONFIG_ONLY:=0}"
: "${SKIP_FEEDS:=0}"

log() {
	printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

die() {
	echo "ERROR: $*" >&2
	exit 1
}

ensure_openwrt_tree() {
	[ -d "${OPENWRT_DIR}" ] || die "OPENWRT_DIR does not exist: ${OPENWRT_DIR}"
	[ -x "${OPENWRT_DIR}/scripts/feeds" ] || die "Not an OpenWrt tree: ${OPENWRT_DIR}"
	[ -f "${OPENWRT_DIR}/feeds.conf.default" ] || die "Missing feeds.conf.default in ${OPENWRT_DIR}"
}

prepare_feeds_conf() {
	log "Preparing feeds.conf"
	cd "${OPENWRT_DIR}"
	cp feeds.conf.default feeds.conf
	cat "${REPO_ROOT}/profiles/feeds.conf.additions" >> feeds.conf
}

update_and_install_feeds() {
	if [ "${SKIP_FEEDS}" = "1" ]; then
		log "Skipping feeds update/install because SKIP_FEEDS=1"
		return 0
	fi

	cd "${OPENWRT_DIR}"
	log "Updating OpenWrt feeds"
	./scripts/feeds update -a
	log "Installing OpenWrt feeds"
	./scripts/feeds install -a
}

patch_r8168_package() {
	local mk="${OPENWRT_DIR}/package/kernel/r8168/Makefile"
	[ -f "$mk" ] || die "r8168 Makefile not found: $mk"

	log "Patching r8168 package metadata to ${R8168_VERSION}"
	sed -i \
		-e "s/^PKG_VERSION:=.*/PKG_VERSION:=${R8168_VERSION}/" \
		-e "s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" \
		-e "s/^PKG_HASH:=.*/PKG_HASH:=${R8168_HASH}/" \
		"$mk"
}

patch_custom_feeds() {
	cd "${OPENWRT_DIR}"

	if [ -f feeds/packages/net/sing-box/Makefile ]; then
		log "Disabling sing-box-tiny package declaration to avoid virtual-provider recursion"
		sed -i '/^[^#].*BuildPackage,sing-box-tiny/s/^/# codex disabled: /' feeds/packages/net/sing-box/Makefile
	fi

	if [ -f feeds/natelol/luci-app-oled/Makefile ]; then
		log "Patching NateLol OLED Makefile for OpenWrt package build"
		sed -i '/LUCI_PKGARCH/d' feeds/natelol/luci-app-oled/Makefile
		sed -i 's/^PKG_RELEASE:=1\.0/PKG_RELEASE:=1/' feeds/natelol/luci-app-oled/Makefile
	fi

	for mk in feeds/podkop/podkop/Makefile feeds/podkop/luci-app-podkop/Makefile; do
		if [ -f "$mk" ]; then
			log "Pinning $(basename "$(dirname "$mk")") package version to ${PODKOP_VERSION}"
			sed -i "s/^PKG_VERSION[[:space:]]*:=.*/PKG_VERSION:=${PODKOP_VERSION}/" "$mk"
		fi
	done

	if [ -f feeds/podkop/luci-app-podkop/Makefile ]; then
		log "Patching luci-app-podkop duplicate BuildPackage declaration"
		sed -i '/^[^#].*BuildPackage,$(PKG_NAME)/s/^/# codex disabled: /' feeds/podkop/luci-app-podkop/Makefile
	fi
}

patch_boot_config() {
	local src="${REPO_ROOT}/patches/bcm27xx/config.txt"
	local dst="${OPENWRT_DIR}/target/linux/bcm27xx/image/config.txt"
	[ -f "$src" ] || die "Missing boot config source: $src"
	[ -f "$dst" ] || die "Missing OpenWrt boot config target: $dst"

	log "Applying bcm27xx boot config"
	cp "$src" "$dst"
}

patch_kernel_hz() {
	local dst="${OPENWRT_DIR}/target/linux/bcm27xx/bcm2711/config-6.12"
	local fragment="${REPO_ROOT}/patches/bcm27xx/config-6.12-hz-1000.fragment"
	local begin="# codex-52pi-hz1000 begin"
	local end="# codex-52pi-hz1000 end"

	[ -f "$dst" ] || die "Missing bcm2711 kernel config: $dst"
	[ -f "$fragment" ] || die "Missing HZ fragment: $fragment"

	log "Applying 1000 Hz kernel timer fragment"
	awk -v begin="$begin" -v end="$end" '
		$0 == begin { skip=1; next }
		$0 == end { skip=0; next }
		!skip { print }
	' "$dst" > "${dst}.tmp"
	{
		cat "${dst}.tmp"
		printf '\n%s\n' "$begin"
		cat "$fragment"
		printf '%s\n' "$end"
	} > "$dst"
	rm -f "${dst}.tmp"
}

prepare_build_tree() {
	ensure_openwrt_tree
	prepare_feeds_conf
	update_and_install_feeds
	patch_r8168_package
	patch_custom_feeds
	patch_boot_config
	patch_kernel_hz
}

apply_files_overlay() {
	local profile="$1"
	local files_dir="${OPENWRT_DIR}/files"

	log "Applying files overlay for ${profile}"
	rm -rf "$files_dir"
	mkdir -p "$files_dir"

	rsync -a "${REPO_ROOT}/files/common/" "$files_dir/"
	if [ -d "${REPO_ROOT}/files/${profile}" ]; then
		rsync -a "${REPO_ROOT}/files/${profile}/" "$files_dir/"
	fi

	find "$files_dir/etc/init.d" "$files_dir/etc/uci-defaults" -type f -exec chmod 0755 {} + 2>/dev/null || true

	if [ -n "${LAN_IP}" ]; then
		mkdir -p "$files_dir/etc/uci-defaults"
		cat > "$files_dir/etc/uci-defaults/20-test-lan-ip" <<EOF
#!/bin/sh

LAN_IP='${LAN_IP}'

uci -q set network.lan.ipaddr="\$LAN_IP"
uci -q commit network

uci -q delete dhcp.lan.dhcp_option
uci -q add_list dhcp.lan.dhcp_option="42,\$LAN_IP"
uci -q commit dhcp

exit 0
EOF
		chmod 0755 "$files_dir/etc/uci-defaults/20-test-lan-ip"
	fi
}

generate_config() {
	local profile="$1"
	local profile_config="${REPO_ROOT}/profiles/${profile}.config"

	[ -f "${REPO_ROOT}/profiles/common.config" ] || die "Missing profiles/common.config"
	[ -f "$profile_config" ] || die "Missing profile config: $profile_config"

	cd "${OPENWRT_DIR}"
	log "Generating .config for ${profile}"
	rm -f .config
	cat "${REPO_ROOT}/profiles/common.config" > .config
	if [ "$profile" = "full-vpn-podkop" ]; then
		cat "${REPO_ROOT}/profiles/performance.config" >> .config
	fi
	cat "$profile_config" >> .config

	bash "${REPO_ROOT}/scripts/packages-to-config.sh" \
		"${REPO_ROOT}/profiles/common-extra-tools.packages.txt" >> .config

	if [ "$profile" = "full-vpn-podkop" ]; then
		bash "${REPO_ROOT}/scripts/packages-to-config.sh" \
			"${REPO_ROOT}/profiles/full-vpn-podkop.production-packages.txt" >> .config
	fi

	make defconfig
	verify_config "$profile"
}

require_config_symbol() {
	local symbol="$1"
	grep -qx "${symbol}=y" "${OPENWRT_DIR}/.config" || die "Required config symbol missing: ${symbol}"
}

verify_config() {
	local profile="$1"

	log "Verifying generated ${profile} config"
	require_config_symbol CONFIG_TARGET_bcm27xx_bcm2711_DEVICE_rpi-4
	require_config_symbol CONFIG_PACKAGE_luci-app-oled
	require_config_symbol CONFIG_PACKAGE_kmod-r8168-rss
	require_config_symbol CONFIG_PACKAGE_ip-full
	require_config_symbol CONFIG_PACKAGE_tc-full
	require_config_symbol CONFIG_PACKAGE_fping
	require_config_symbol CONFIG_PACKAGE_tcpdump
	require_config_symbol CONFIG_PACKAGE_chrony
	require_config_symbol CONFIG_PACKAGE_luci-app-sqm

	grep -qx 'CONFIG_TARGET_KERNEL_PARTSIZE=128' "${OPENWRT_DIR}/.config" || die "Kernel partition size is not 128"
	grep -qx 'CONFIG_TARGET_ROOTFS_PARTSIZE=2048' "${OPENWRT_DIR}/.config" || die "Root partition size is not 2048"

	if [ "$profile" = "full-vpn-podkop" ]; then
		require_config_symbol CONFIG_PACKAGE_kmod-amneziawg
		require_config_symbol CONFIG_PACKAGE_amneziawg-tools
		require_config_symbol CONFIG_PACKAGE_luci-proto-amneziawg
		require_config_symbol CONFIG_PACKAGE_podkop
		require_config_symbol CONFIG_PACKAGE_luci-app-podkop
		require_config_symbol CONFIG_PACKAGE_sing-box
	fi
}

build_profile() {
	local profile="$1"

	prepare_build_tree
	apply_files_overlay "$profile"
	generate_config "$profile"

	if [ "${CONFIG_ONLY}" = "1" ]; then
		log "CONFIG_ONLY=1, stopping before firmware compile"
		return 0
	fi

	cd "${OPENWRT_DIR}"
	log "Starting firmware build for ${profile} with JOBS=${JOBS}"
	make -j"${JOBS}" V=s
	bash "${REPO_ROOT}/scripts/collect-artifacts.sh" "$profile"
}
