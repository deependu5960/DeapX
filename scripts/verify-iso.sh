#!/usr/bin/env bash
# DeapX OS — verify produced ISO
set -euo pipefail
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

verify_iso() {
    local iso="${1:?ISO path required}"
    [[ -f "${iso}" ]] || die "ISO not found: ${iso}"
    local size
    size="$(stat -c%s "${iso}")"
    if [[ "${size}" -lt 104857600 ]]; then
        die "ISO is suspiciously small (${size} bytes)."
    fi
    if check_command file; then
        local mime
        mime="$(file -b "${iso}")"
        if ! echo "${mime}" | grep -qiE 'iso|9660|boot|archive'; then
            log_warn "Unexpected file type: ${mime}"
        fi
    fi
    if check_command xorriso; then
        if xorriso -indev "${iso}" -report_el_torito as_mkisofs 2>/dev/null | grep -qi 'boot'; then
            log_info "ISO contains El Torito boot entries."
        else
            log_warn "ISO may lack El Torito boot entries."
        fi
    fi
    if check_command fdisk; then
        if fdisk -l "${iso}" 2>/dev/null | grep -qi 'EFI'; then
            log_info "ISO contains EFI partition (UEFI boot capable)."
        else
            log_warn "ISO may lack EFI partition."
        fi
    fi
    log_info "ISO verification passed: ${iso}"
    log_info "SHA256: $(sha256sum "${iso}" | cut -d' ' -f1)"
}

verify_iso "$@"
