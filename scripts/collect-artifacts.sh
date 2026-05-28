#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

: "${OPENWRT_DIR:=/home/olafnew/build/src/openwrt-25.12.4}"

profile="${1:-}"
[ -n "$profile" ] || { echo "Usage: collect-artifacts.sh <profile>" >&2; exit 2; }

target_dir="${OPENWRT_DIR}/bin/targets/bcm27xx/bcm2711"
[ -d "$target_dir" ] || { echo "Target output directory not found: $target_dir" >&2; exit 1; }

stamp="$(date -u '+%Y%m%d-%H%M%SZ')"
out_dir="${REPO_ROOT}/releases/${stamp}-${profile}"
mkdir -p "$out_dir"

cp -a "${OPENWRT_DIR}/.config" "$out_dir/config.full"
"${OPENWRT_DIR}/scripts/diffconfig.sh" > "$out_dir/config.diff" || true
cp -a "${OPENWRT_DIR}/feeds.conf" "$out_dir/feeds.conf"

find "$target_dir" -maxdepth 1 -type f \
	\( -name '*.img.gz' -o -name '*.manifest' -o -name '*.buildinfo' -o -name 'sha256sums' -o -name 'profiles.json' \) \
	-exec cp -a {} "$out_dir/" \;

(
	cd "$out_dir"
	sha256sum * > SHA256SUMS.generated
)

printf '%s\n' "$out_dir"
