#!/usr/bin/env bash
# DeapX OS — verify build host dependencies
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
load_config "${ROOT_DIR}/config/build.conf"

readonly REQUIRED_PACKAGES=(
    live-build
    debootstrap
    squashfs-tools
    xorriso
    isolinux
    syslinux
    syslinux-common
    mtools
    dosfstools
    grub-efi-amd64-bin
    grub-pc-bin
    grub-common
    shim-signed
    shim-helpers-amd64-signed
    rsync
    wget
    curl
    git
    debian-archive-keyring
    ca-certificates
    gnupg
    apt-utils
    dpkg-dev
    binutils
    patch
    gzip
    bzip2
    xz-utils
    zstd
    file
    util-linux
    kpartx
)

check_host_os() {
    if [[ ! -f /etc/debian_version ]]; then
        log_warn "Build host is not Debian. Build may still work but is unsupported."
    fi
}

check_commands() {
    local missing=()
    local cmds=(lb debootstrap mksquashfs xorriso rsync wget curl)
    local cmd
    for cmd in "${cmds[@]}"; do
        if ! check_command "${cmd}"; then
            missing+=("${cmd}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing commands: ${missing[*]}. Install live-build and required tools."
    fi
}

check_packages() {
    local missing=()
    local pkg
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
            missing+=("${pkg}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_info "Installing missing packages: ${missing[*]}"
        export_debian_env
        apt-get update -qq
        apt-get install -y --no-install-recommends "${missing[@]}"
    fi
}

check_resources() {
    check_disk_space "${MIN_DISK_SPACE_GB}" "${ROOT_DIR}"
    check_ram "${MIN_RAM_GB}"
}

main() {
    log_info "Checking build dependencies..."
    check_host_os
    check_commands
    check_packages
    check_resources
    log_info "All dependencies satisfied."
}

main "$@"
