#!/usr/bin/env bash
# DeapX OS — set executable permissions on build scripts and hooks
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

main() {
    log_info "Setting file permissions..."
    chmod 0755 "${ROOT_DIR}/build.sh"
    chmod 0755 "${ROOT_DIR}/auto/config"
    chmod 0755 "${ROOT_DIR}/auto/clean"
    chmod 0755 "${ROOT_DIR}/scripts/"*.sh
    chmod 0755 "${ROOT_DIR}/scripts/lib/common.sh"
    if [[ -d "${ROOT_DIR}/hooks/normal" ]]; then
        find "${ROOT_DIR}/hooks/normal" -type f -name '*.hook.chroot' -exec chmod 0755 {} +
    fi
    if [[ -d "${ROOT_DIR}/hooks/live" ]]; then
        find "${ROOT_DIR}/hooks/live" -type f -name '*.hook' -exec chmod 0755 {} +
    fi
    log_info "Permissions set."
}

main "$@"
