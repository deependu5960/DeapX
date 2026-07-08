#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Deap X Operating System - Build Script
# Version: 1.0.0
# Description: Production-grade Debian Live ISO builder with Brave Browser
#

set -o errexit   # Exit on any command failure
set -o nounset   # Exit on unset variable
set -o pipefail  # Pipe failures cause exit
set -o errtrace  # Trap errors in functions and subshells

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_NAME="Deap X"
readonly PROJECT_VERSION="1.0.0"
readonly ISO_NAME="deapx.iso"
readonly DISTRO_CODENAME="bookworm"
readonly ARCHITECTURE="amd64"
readonly BUILD_PROFILE="${1:-standard}"  # Default: standard

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#-------------------------------------------------------------------------------
# LOGGING FUNCTIONS
#-------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

#-------------------------------------------------------------------------------
# ERROR HANDLING
#-------------------------------------------------------------------------------

error_handler() {
    local line_no=$1
    local error_code=$2
    log_error "Build failed at line ${line_no} with exit code ${error_code}"
    exit "${error_code}"
}

trap 'error_handler ${LINENO} $?' ERR

#-------------------------------------------------------------------------------
# DEPENDENCY CHECK
#-------------------------------------------------------------------------------

check_dependencies() {
    log_info "Checking build dependencies..."
    
    local required_commands=(
        "lb"
        "debootstrap"
        "xorriso"
        "squashfs-tools"
        "cpio"
        "gzip"
        "rsync"
        "wget"
        "curl"
        "git"
    )
    
    local missing_deps=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing_deps+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Install missing dependencies with:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install live-build debootstrap xorriso \\"
        echo "    squashfs-tools cpio gzip rsync wget curl git"
        exit 1
    fi
    
    log_success "All dependencies satisfied"
}

#-------------------------------------------------------------------------------
# DIRECTORY SETUP
#-------------------------------------------------------------------------------

setup_directories() {
    log_info "Setting up build directories..."
    
    local directories=(
        "${SCRIPT_DIR}/config"
        "${SCRIPT_DIR}/packages"
        "${SCRIPT_DIR}/overlays"
        "${SCRIPT_DIR}/profiles/${BUILD_PROFILE}"
        "${SCRIPT_DIR}/scripts"
        "${SCRIPT_DIR}/output"
        "${SCRIPT_DIR}/cache"
        "${SCRIPT_DIR}/config/hooks/normal"
        "${SCRIPT_DIR}/config/hooks/live"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}"
            log_info "Created directory: ${dir}"
        fi
    done
    
    # Clean previous build artifacts
    if [[ -d "${SCRIPT_DIR}/config" ]]; then
        log_info "Cleaning previous live-build configuration..."
        lb clean --purge 2>/dev/null || true
    fi
}

#-------------------------------------------------------------------------------
# LOAD PROFILE CONFIGURATION
#-------------------------------------------------------------------------------

load_profile() {
    log_info "Loading build profile: ${BUILD_PROFILE}"
    
    local profile_dir="${SCRIPT_DIR}/profiles/${BUILD_PROFILE}"
    
    if [[ ! -d "${profile_dir}" ]]; then
        log_error "Profile '${BUILD_PROFILE}' not found in profiles/"
        log_info "Available profiles:"
        find "${SCRIPT_DIR}/profiles" -type d -mindepth 1 -maxdepth 1 -exec basename {} \;
        exit 1
    fi
    
    # Source profile configuration
    if [[ -f "${profile_dir}/config" ]]; then
        source "${profile_dir}/config"
        log_info "Loaded profile configuration"
    fi
    
    # Merge profile packages if specified
    if [[ -f "${profile_dir}/packages.list" ]]; then
        export PROFILE_PACKAGES_FILE="${profile_dir}/packages.list"
        log_info "Profile packages file: ${PROFILE_PACKAGES_FILE}"
    fi
}

#-------------------------------------------------------------------------------
# CONFIGURE LIVE-BUILD
#-------------------------------------------------------------------------------

configure_live_build() {
    log_info "Configuring live-build environment..."
    
    # Change to script directory (where lb commands run)
    cd "${SCRIPT_DIR}"
    
    # Clear any existing configuration
    lb clean --purge 2>/dev/null || true
    
    # Bootstrap configuration
    export LB_BOOTSTRAP="debootstrap"
    export LB_BOOTSTRAP_ARCHIVE="http://deb.debian.org/debian"
    export LB_BOOTSTRAP_ARCHIVE_SUITE="${DISTRO_CODENAME}"
    export LB_BOOTSTRAP_ARCHIVE_AREAS="main contrib non-free non-free-firmware"
    export LB_BOOTSTRAP_CACHE="true"
    export LB_BOOTSTRAP_CACHE_INDICES="true"
    export LB_BOOTSTRAP_CACHE_PACKAGES="true"
    export LB_BOOTSTRAP_CACHE_PACKAGES_PATH="cache/bootstrap"
    export LB_BOOTSTRAP_SECURITY="true"
    export LB_BOOTSTRAP_SECURITY_ARCHIVE="http://security.debian.org/debian-security"
    export LB_BOOTSTRAP_SECURITY_ARCHIVE_SUITE="${DISTRO_CODENAME}-security"
    export LB_BOOTSTRAP_SECURITY_ARCHIVE_AREAS="main contrib non-free non-free-firmware"
    export LB_BOOTSTRAP_UPDATES="true"
    export LB_BOOTSTRAP_UPDATES_ARCHIVE="http://deb.debian.org/debian"
    export LB_BOOTSTRAP_UPDATES_ARCHIVE_SUITE="${DISTRO_CODENAME}-updates"
    export LB_BOOTSTRAP_UPDATES_ARCHIVE_AREAS="main contrib non-free non-free-firmware"
    export LB_BOOTSTRAP_BACKPORTS="false"
    
    # Build configuration
    export LB_BUILD_IN="chroot"
    export LB_BUILD_OUT="iso-hybrid"
    export LB_BUILD_LIVE="true"
    export LB_BUILD_SQUASHFS="true"
    export LB_BUILD_SQUASHFS_COMPRESSION="xz"
    export LB_BUILD_SQUASHFS_COMPRESSION_OPTIONS="-Xbcj x86"
    export LB_BUILD_WITH_CHROOT="true"
    export LB_BUILD_WITH_SOURCE="false"
    
    # Chroot configuration
    export LB_CHROOT_FILESYSTEM="squashfs"
    export LB_CHROOT_HOSTNAME="deapx-live"
    export LB_CHROOT_PASSWD="live"
    export LB_CHROOT_USERNAME="user"
    export LB_CHROOT_USER_FULLNAME="Deap X User"
    export LB_CHROOT_USER_PASSWORD="live"
    export LB_CHROOT_USER_GROUPS="audio,cdrom,dip,floppy,netdev,plugdev,powerdev,scanner,sudo,video"
    export LB_CHROOT_USER_HOME="/home/user"
    export LB_CHROOT_USER_SHELL="/bin/bash"
    
    # Binary configuration
    export LB_BINARY_IMAGES="iso-hybrid"
    export LB_BINARY_FILESYSTEM="fat16"
    export LB_BINARY_FILESYSTEM_LABEL="DEAPX_LIVE"
    export LB_BINARY_ISO_VOLUME="${PROJECT_NAME} ${PROJECT_VERSION} Live ISO"
    export LB_BINARY_ISO_PUBLISHER="${PROJECT_NAME} Operating System"
    export LB_BINARY_ISO_APPLICATION="${PROJECT_NAME} Live System"
    export LB_BINARY_ISO_PREPARER="Live-build 1.0.0"
    export LB_BINARY_ISO_SYSTEM="Debian GNU/Linux"
    export LB_BINARY_ISO_COPYRIGHT="GPL-3.0"
    
    # Bootloader configuration
    export LB_BOOTLOADER="syslinux"
    export LB_BOOTLOADER_CONFIG_FILE="isolinux.cfg"
    export LB_BOOTLOADER_CONFIG_PATH="isolinux/"
    export LB_BOOTLOADER_MENU_TITLE="${PROJECT_NAME} Live System"
    export LB_BOOTLOADER_MENU_TIMEOUT="300"
    export LB_BOOTLOADER_MENU_DEFAULT="live"
    
    # System configuration
    export LB_SYSTEM="live"
    export LB_SYSTEM_LOCALE="en_US.UTF-8"
    export LB_SYSTEM_TIMEZONE="UTC"
    export LB_SYSTEM_KEYBOARD="us"
    export LB_SYSTEM_LANGUAGE="en_US:en"
    
    # Generate the live-build configuration
    lb config \
        --bootstrap "${LB_BOOTSTRAP}" \
        --bootstrap-archive "${LB_BOOTSTRAP_ARCHIVE}" \
        --bootstrap-archive-suite "${LB_BOOTSTRAP_ARCHIVE_SUITE}" \
        --bootstrap-archive-areas "${LB_BOOTSTRAP_ARCHIVE_AREAS}" \
        --build "${LB_BUILD_IN}" \
        --output "${LB_BUILD_OUT}" \
        --live "${LB_BUILD_LIVE}" \
        --squashfs "${LB_BUILD_SQUASHFS}" \
        --chroot-filesystem "${LB_CHROOT_FILESYSTEM}" \
        --binary-images "${LB_BINARY_IMAGES}" \
        --binary-filesystem "${LB_BINARY_FILESYSTEM}" \
        --bootloader "${LB_BOOTLOADER}" \
        --system "${LB_SYSTEM}" \
        --hostname "${LB_CHROOT_HOSTNAME}" \
        --username "${LB_CHROOT_USERNAME}" \
        --user-fullname "${LB_CHROOT_USER_FULLNAME}" \
        --user-password "${LB_CHROOT_USER_PASSWORD}" \
        --archive-areas "${LB_BOOTSTRAP_ARCHIVE_AREAS}" \
        --iso-volume "${LB_BINARY_ISO_VOLUME}" \
        --iso-publisher "${LB_BINARY_ISO_PUBLISHER}" \
        --iso-application "${LB_BINARY_ISO_APPLICATION}" \
        --iso-preparer "${LB_BINARY_ISO_PREPARER}" \
        --memtest "none" \
        --apt-recommends "true" \
        --apt-secure "true" \
        --cache "${LB_BOOTSTRAP_CACHE}" \
        --cache-indices "${LB_BOOTSTRAP_CACHE_INDICES}" \
        --cache-packages "${LB_BOOTSTRAP_CACHE_PACKAGES}" \
        --cache-packages-path "${LB_BOOTSTRAP_CACHE_PACKAGES_PATH}" \
        --security "${LB_BOOTSTRAP_SECURITY}" \
        --security-archive "${LB_BOOTSTRAP_SECURITY_ARCHIVE}" \
        --security-archive-suite "${LB_BOOTSTRAP_SECURITY_ARCHIVE_SUITE}" \
        --security-archive-areas "${LB_BOOTSTRAP_SECURITY_ARCHIVE_AREAS}" \
        --updates "${LB_BOOTSTRAP_UPDATES}" \
        --updates-archive "${LB_BOOTSTRAP_UPDATES_ARCHIVE}" \
        --updates-archive-suite "${LB_BOOTSTRAP_UPDATES_ARCHIVE_SUITE}" \
        --updates-archive-areas "${LB_BOOTSTRAP_UPDATES_ARCHIVE_AREAS}" \
        --backports "${LB_BOOTSTRAP_BACKPORTS}" \
        --locale "${LB_SYSTEM_LOCALE}" \
        --timezone "${LB_SYSTEM_TIMEZONE}" \
        --keyboard-layout "${LB_SYSTEM_KEYBOARD}"
    
    log_success "Live-build configuration completed"
    
    # Copy package lists
    if [[ -d "${SCRIPT_DIR}/packages" ]]; then
        cp -r "${SCRIPT_DIR}/packages/"*.list "config/package-lists/" 2>/dev/null || true
        log_info "Copied package lists"
    fi
    
    # Copy profile packages if specified
    if [[ -n "${PROFILE_PACKAGES_FILE:-}" ]] && [[ -f "${PROFILE_PACKAGES_FILE}" ]]; then
        cp "${PROFILE_PACKAGES_FILE}" "config/package-lists/profile.list"
        log_info "Added profile-specific packages"
    fi
}

#-------------------------------------------------------------------------------
# APPLY OVERLAYS
#-------------------------------------------------------------------------------

apply_overlays() {
    log_info "Applying system overlays..."
    
    local overlay_dir="${SCRIPT_DIR}/overlays"
    
    if [[ -d "${overlay_dir}" ]]; then
        # Copy overlays to chroot directory
        if [[ -d "${SCRIPT_DIR}/config/chroot_local-includes" ]]; then
            rm -rf "${SCRIPT_DIR}/config/chroot_local-includes"
        fi
        mkdir -p "${SCRIPT_DIR}/config/chroot_local-includes"
        
        # Copy all overlay files
        cp -r "${overlay_dir}"/* "${SCRIPT_DIR}/config/chroot_local-includes/" 2>/dev/null || true
        
        log_success "Overlays applied"
    else
        log_warning "No overlays found at ${overlay_dir}"
    fi
}

#-------------------------------------------------------------------------------
# RUN PRE-BUILD SCRIPTS
#-------------------------------------------------------------------------------

run_pre_build_scripts() {
    log_info "Executing pre-build scripts..."
    
    local scripts_dir="${SCRIPT_DIR}/scripts"
    
    if [[ -f "${scripts_dir}/pre-build.sh" ]]; then
        log_info "Running pre-build.sh"
        source "${scripts_dir}/pre-build.sh"
        pre_build
    fi
    
    if [[ -f "${scripts_dir}/chroot-pre-install.sh" ]]; then
        log_info "Copying chroot-pre-install.sh to hooks"
        cp "${scripts_dir}/chroot-pre-install.sh" "${SCRIPT_DIR}/config/hooks/normal/"
        chmod +x "${SCRIPT_DIR}/config/hooks/normal/chroot-pre-install.sh"
    fi
}

#-------------------------------------------------------------------------------
# RUN POST-BUILD SCRIPTS
#-------------------------------------------------------------------------------

run_post_build_scripts() {
    log_info "Executing post-build scripts..."
    
    local scripts_dir="${SCRIPT_DIR}/scripts"
    
    if [[ -f "${scripts_dir}/chroot-post-install.sh" ]]; then
        log_info "Copying chroot-post-install.sh to hooks"
        cp "${scripts_dir}/chroot-post-install.sh" "${SCRIPT_DIR}/config/hooks/normal/"
        chmod +x "${SCRIPT_DIR}/config/hooks/normal/chroot-post-install.sh"
    fi
}

#-------------------------------------------------------------------------------
# BUILD ISO
#-------------------------------------------------------------------------------

build_iso() {
    log_info "Building Debian Live ISO (this may take a while)..."
    
    cd "${SCRIPT_DIR}"
    
    # Build the ISO
    lb build 2>&1 | tee "${SCRIPT_DIR}/build.log"
    
    local build_exit_code=${PIPESTATUS[0]}
    
    if [[ ${build_exit_code} -ne 0 ]]; then
        log_error "Build failed. Check build.log for details."
        exit 1
    fi
    
    log_success "ISO build completed successfully"
}

#-------------------------------------------------------------------------------
# MOVE ISO TO OUTPUT
#-------------------------------------------------------------------------------

move_iso_to_output() {
    log_info "Moving ISO to output directory..."
    
    local iso_file="${SCRIPT_DIR}/live-image-${ARCHITECTURE}.hybrid.iso"
    local output_file="${SCRIPT_DIR}/output/${ISO_NAME}"
    
    if [[ -f "${iso_file}" ]]; then
        mv "${iso_file}" "${output_file}"
        log_success "ISO moved to ${output_file}"
        
        # Create SHA256 checksum
        cd "${SCRIPT_DIR}/output"
        sha256sum "${ISO_NAME}" > "${ISO_NAME}.sha256"
        log_info "SHA256 checksum created"
        
        # Create MD5 checksum
        md5sum "${ISO_NAME}" > "${ISO_NAME}.md5"
        log_info "MD5 checksum created"
        
        # Display file information
        local file_size=$(du -h "${ISO_NAME}" | cut -f1)
        log_info "ISO Size: ${file_size}"
    else
        log_error "ISO file not found at ${iso_file}"
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# CLEANUP
#-------------------------------------------------------------------------------

cleanup() {
    log_info "Cleaning up build artifacts..."
    
    # Preserve the output directory and cache
    if [[ -d "${SCRIPT_DIR}/output" ]] && [[ -d "${SCRIPT_DIR}/cache" ]]; then
        log_info "Build artifacts preserved in cache/"
    fi
    
    # Remove temporary build files but keep configuration
    cd "${SCRIPT_DIR}"
    lb clean 2>/dev/null || true
    
    log_success "Cleanup completed"
}

#-------------------------------------------------------------------------------
# MAIN FUNCTION
#-------------------------------------------------------------------------------

main() {
    log_info "Starting ${PROJECT_NAME} build system v${PROJECT_VERSION}"
    log_info "Build profile: ${BUILD_PROFILE}"
    log_info "Architecture: ${ARCHITECTURE}"
    log_info "Distribution: ${DISTRO_CODENAME}"
    log_info "Default Browser: Brave"
    
    # Check if running as root (required for live-build)
    if [[ ${EUID} -ne 0 ]]; then
        log_warning "This script should be run as root for live-build"
        log_warning "Some features may not work properly"
    fi
    
    # Execute build stages
    check_dependencies
    setup_directories
    load_profile
    configure_live_build
    apply_overlays
    run_pre_build_scripts
    run_post_build_scripts
    build_iso
    move_iso_to_output
    cleanup
    
    log_success "${PROJECT_NAME} build completed successfully!"
    log_info "ISO located at: ${SCRIPT_DIR}/output/${ISO_NAME}"
    log_info "SHA256: $(cat ${SCRIPT_DIR}/output/${ISO_NAME}.sha256 2>/dev/null || echo 'N/A')"
    log_info "To boot, write ISO to USB: sudo dd if=${SCRIPT_DIR}/output/${ISO_NAME} of=/dev/sdX bs=4M status=progress"
}

#-------------------------------------------------------------------------------
# SCRIPT EXECUTION
#-------------------------------------------------------------------------------

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi