#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "DeapX Build System - Revision A"
echo "========================================="
echo ""

# Read VERSION file
echo "[1/6] Reading VERSION file..."
if [ ! -f "$PROJECT_ROOT/VERSION" ]; then
    echo "ERROR: VERSION file not found!"
    exit 1
fi
VERSION_FILE=$(cat "$PROJECT_ROOT/VERSION")
echo "  VERSION: $VERSION_FILE"

# Read configuration
echo "[2/6] Reading configuration..."
if [ ! -f "$PROJECT_ROOT/config/deapx.conf" ]; then
    echo "ERROR: config/deapx.conf not found!"
    exit 1
fi
source "$PROJECT_ROOT/config/deapx.conf"
echo "  Configuration loaded."

# Validate configuration
echo "[3/6] Validating configuration..."
REQUIRED_VARS=("NAME" "VERSION" "DEBIAN_RELEASE" "ARCH" "PROFILE")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required variable $var is not set in config/deapx.conf"
        exit 1
    fi
done

if [ "$VERSION_FILE" != "$VERSION" ]; then
    echo "ERROR: VERSION file ($VERSION_FILE) does not match config/deapx.conf ($VERSION)"
    exit 1
fi

VALID_ARCHS=("amd64" "i386" "arm64" "armhf")
if [[ ! " ${VALID_ARCHS[@]} " =~ " ${ARCH} " ]]; then
    echo "ERROR: Invalid ARCH: $ARCH"
    exit 1
fi

VALID_PROFILES=("developer" "release" "debug")
if [[ ! " ${VALID_PROFILES[@]} " =~ " ${PROFILE} " ]]; then
    echo "ERROR: Invalid PROFILE: $PROFILE"
    exit 1
fi

echo "  Configuration valid."

# Check dependencies
echo "[4/6] Checking dependencies..."
DEPENDENCIES=("lb" "debootstrap" "xorriso" "rsync")
MISSING_DEPS=()

for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "ERROR: Missing dependencies: ${MISSING_DEPS[*]}"
    echo "  Install with: sudo apt-get install live-build debootstrap xorriso rsync"
    exit 1
fi
echo "  All dependencies satisfied."

# Verify repository structure
echo "[5/6] Verifying repository structure..."
REQUIRED_DIRS=(
    "config"
    "build"
    "live-build/auto"
    "live-build/config"
    "live-build/hooks"
    "live-build/includes"
    "live-build/package-lists"
    "live-build/profiles/developer"
    "live-build/profiles/release"
    "live-build/profiles/debug"
    "branding"
    "boot"
    "login"
    "desktop"
    "applications"
    "packages"
    "assets"
    "scripts"
    "iso"
    "testing"
    "releases"
    "future"
)

MISSING_DIRS=()
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$PROJECT_ROOT/$dir" ]; then
        MISSING_DIRS+=("$dir")
    fi
done

if [ ${#MISSING_DIRS[@]} -gt 0 ]; then
    echo "WARNING: Missing directories:"
    for dir in "${MISSING_DIRS[@]}"; do
        echo "  - $dir"
    done
else
    echo "  Repository structure complete."
fi

# Prepare live-build
echo "[6/6] Preparing live-build environment..."
LB_CONFIG_DIR="$PROJECT_ROOT/live-build/config"
LB_AUTO_DIR="$PROJECT_ROOT/live-build/auto"

if [ ! -d "$LB_CONFIG_DIR" ]; then
    echo "ERROR: live-build/config directory not found!"
    exit 1
fi

echo "  Setting up live-build configuration..."
export LB_BASE="$PROJECT_ROOT/live-build"
echo "  Live-build base directory: $LB_BASE"

echo ""
echo "========================================="
echo "Build environment prepared successfully!"
echo "========================================="
echo "Project: $NAME"
echo "Version: $VERSION"
echo "Debian Release: $DEBIAN_RELEASE"
echo "Architecture: $ARCH"
echo "Profile: $PROFILE"
echo ""
echo "Build environment is ready for ISO generation."
echo "========================================="

exit 0