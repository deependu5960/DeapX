#!/usr/bin/env bash
# DeapX OS — shared library functions
set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

die() {
    log_error "$@"
    exit 1
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "This script must be run as root (use sudo)."
    fi
}

load_config() {
    local conf_file="${1:?Config file required}"
    if [[ ! -f "${conf_file}" ]]; then
        die "Configuration file not found: ${conf_file}"
    fi
    # shellcheck source=/dev/null
    source "${conf_file}"
    export DISTRIBUTION ARCHITECTURE ARCHIVE_AREAS ISO_OUTPUT_NAME
    export LIVE_USERNAME LIVE_FULLNAME LIVE_PASSWORD
    export HOSTNAME DOMAINNAME LOCALE_DEFAULT KEYMAP
    export KERNEL_PACKAGES FIRMWARE_PACKAGES
    export PLYMOUTH_THEME GRUB_DEFAULT GRUB_TIMEOUT
    export LB_MEMTEST LB_WIN32_LOADER LB_APT_INDICES LB_APT_RECOMMENDS
    export LB_DEBIAN_INSTALLER LB_FIRMWARE_CHROOT LB_FIRMWARE_BINARY
    export LB_INITRAMFS_COMPRESSION LB_LINUX_FLAVOURS
    export LB_SECURITY LB_UPDATES LB_BACKPORTS
    export MIN_DISK_SPACE_GB MIN_RAM_GB
}

validate_config() {
    [[ -n "${DISTRIBUTION}" ]]    || die "DISTRIBUTION is not set"
    [[ -n "${ARCHITECTURE}" ]]    || die "ARCHITECTURE is not set"
    [[ -n "${ISO_OUTPUT_NAME}" ]] || die "ISO_OUTPUT_NAME is not set"
    [[ -n "${LIVE_USERNAME}" ]]   || die "LIVE_USERNAME is not set"
    [[ -n "${HOSTNAME}" ]]        || die "HOSTNAME is not set"
}

check_command() {
    command -v "${1:?Command required}" >/dev/null 2>&1
}

check_disk_space() {
    local required_gb="${1:?GB required}"
    local path="${2:-.}"
    local available_kb
    available_kb="$(df -k "${path}" | awk 'NR==2 {print $4}')"
    local required_kb=$((required_gb * 1024 * 1024))
    if [[ "${available_kb}" -lt "${required_kb}" ]]; then
        die "Insufficient disk space. Need ${required_gb}GB, have $((available_kb / 1024 / 1024))GB."
    fi
}

check_ram() {
    local required_gb="${1:?GB required}"
    local available_kb
    available_kb="$(grep MemAvailable /proc/meminfo | awk '{print $2}')"
    local required_kb=$((required_gb * 1024 * 1024))
    if [[ "${available_kb}" -lt "${required_kb}" ]]; then
        log_warn "Low RAM: recommended ${required_gb}GB, available $((available_kb / 1024 / 1024))GB."
    fi
}

find_iso() {
    local candidate
    for candidate in "$@"; do
        if [[ -f "${candidate}" ]]; then
            echo "${candidate}"
            return 0
        fi
    done
    candidate="$(find . -maxdepth 2 \( -name 'live-image-*.hybrid.iso' -o -name 'live-image-*.iso' -o -name 'deapx-os-*.iso' \) -type f 2>/dev/null | head -1)"
    if [[ -n "${candidate}" ]]; then
        echo "${candidate}"
    fi
}

export_debian_env() {
    export DEBIAN_FRONTEND=noninteractive
    export LC_ALL=C.UTF-8
    export DISTRIBUTION ARCHITECTURE ARCHIVE_AREAS ISO_OUTPUT_NAME
    export LIVE_USERNAME LIVE_FULLNAME LIVE_PASSWORD
    export HOSTNAME DOMAINNAME LOCALE_DEFAULT KEYMAP
    export KERNEL_PACKAGES FIRMWARE_PACKAGES
    export PLYMOUTH_THEME GRUB_DEFAULT GRUB_TIMEOUT
    export LB_MEMTEST LB_WIN32_LOADER LB_APT_INDICES LB_APT_RECOMMENDS
    export LB_DEBIAN_INSTALLER LB_FIRMWARE_CHROOT LB_FIRMWARE_BINARY
    export LB_INITRAMFS_COMPRESSION LB_LINUX_FLAVOURS
    export LB_SECURITY LB_UPDATES LB_BACKPORTS
}
