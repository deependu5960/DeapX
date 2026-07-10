#!/usr/bin/env bash
# DeapX OS — main build entry point
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BUILD_CONF="${SCRIPT_DIR}/config/build.conf"
source "${SCRIPT_DIR}/scripts/lib/common.sh"

main() {
    log_info "DeapX OS Build System"
    log_info "====================="
    require_root
    load_config "${BUILD_CONF}"
    validate_config
    "${SCRIPT_DIR}/scripts/setup-perms.sh"
    "${SCRIPT_DIR}/scripts/check-deps.sh"
    "${SCRIPT_DIR}/scripts/clean.sh"
    "${SCRIPT_DIR}/scripts/configure.sh"
    log_info "Starting live-build (this may take a long time)..."
    cd "${SCRIPT_DIR}"
    lb build 2>&1 | tee "${SCRIPT_DIR}/build.log"
    local iso_path=""
    iso_path="$(find_iso \
        "${SCRIPT_DIR}/${ISO_OUTPUT_NAME}" \
        "${SCRIPT_DIR}/live-image-amd64.hybrid.iso" \
        "${SCRIPT_DIR}/live-image-amd64.iso")"
    if [[ -z "${iso_path}" ]]; then
        die "Build completed but no ISO was found."
    fi
    local final_iso="${SCRIPT_DIR}/${ISO_OUTPUT_NAME}"
    if [[ "${iso_path}" != "${final_iso}" ]]; then
        cp -f "${iso_path}" "${final_iso}"
    fi
    "${SCRIPT_DIR}/scripts/verify-iso.sh" "${final_iso}"
    log_info "Build successful."
    log_info "ISO: ${final_iso}"
    log_info "Size: $(du -h "${final_iso}" | cut -f1)"
}

main "$@"
