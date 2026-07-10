#!/usr/bin/env bash
# DeapX OS — clean previous build artifacts
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
load_config "${ROOT_DIR}/config/build.conf"

safe_unmount_chroot() {
    local chroot_dir="${ROOT_DIR}/.chroot"
    if [[ -d "${chroot_dir}" ]]; then
        log_info "Checking for active mount points in ${chroot_dir}..."
        local mounts
        # Search for mounts matching .chroot and sort in reverse order to unmount deepest paths first
        mounts="$(mount | grep "${chroot_dir}" | awk '{print $3}' | sort -r)" || true
        if [[ -n "${mounts}" ]]; then
            log_warn "Found active mounts in chroot. Unmounting..."
            for mnt in ${mounts}; do
                log_info "Unmounting ${mnt}..."
                umount -lf "${mnt}" || true
            done
        fi
    fi
}

clean_lb_artifacts() {
    local dirs=(
        .cache
        .chroot
        .binary
        .source
        .build
        config/bootstrap
        config/chroot
        config/common
        config/binary
        config/source
    )
    local dir
    for dir in "${dirs[@]}"; do
        if [[ -d "${ROOT_DIR}/${dir}" ]]; then
            log_info "Removing ${dir}/"
            rm -rf "${ROOT_DIR:?}/${dir}"
        fi
    done
}

clean_config_links() {
    local links=(hooks includes.chroot package-lists)
    local link
    for link in "${links[@]}"; do
        if [[ -L "${ROOT_DIR}/config/${link}" ]]; then
            rm -f "${ROOT_DIR}/config/${link}"
        fi
    done
}

clean_iso_artifacts() {
    find "${ROOT_DIR}" -maxdepth 1 \( \
        -name 'live-image-*.iso' \
        -o -name 'live-image-*.img' \
        -o -name 'live-image-*.zip' \
        -o -name 'live-image-*.tar*' \
        -o -name 'deapx-os-*.iso' \
    \) -type f -exec rm -f {} +
}

clean_logs() {
    rm -f "${ROOT_DIR}/build.log"
}

main() {
    log_info "Cleaning previous build artifacts..."
    cd "${ROOT_DIR}"
    if check_command lb && [[ -f "${ROOT_DIR}/config/auto/config" ]]; then
        lb clean --purge 2>/dev/null || true
    fi
    safe_unmount_chroot
    clean_lb_artifacts
    clean_config_links
    # Also clean build.env from chroot includes if it exists
    rm -f "${ROOT_DIR}/includes.chroot/usr/share/deapx/build.env"
    clean_iso_artifacts
    clean_logs
    log_info "Clean complete."
}

main "$@"
