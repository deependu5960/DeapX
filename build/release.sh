#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "DeapX Build System - Release Preparation"
echo "========================================="
echo ""

# Read configuration
if [ ! -f "$PROJECT_ROOT/config/deapx.conf" ]; then
    echo "ERROR: config/deapx.conf not found!"
    exit 1
fi
source "$PROJECT_ROOT/config/deapx.conf"

RELEASE_DIR="$PROJECT_ROOT/releases/$VERSION"
echo "Preparing release for $NAME version $VERSION"
echo ""

# Create release directory
echo "[1/4] Creating release directory..."
if [ -d "$RELEASE_DIR" ]; then
    echo "  Release directory already exists: $RELEASE_DIR"
else
    mkdir -p "$RELEASE_DIR"
    echo "  Created: $RELEASE_DIR"
fi

# Copy configuration
echo "[2/4] Storing release configuration..."
cp "$PROJECT_ROOT/config/deapx.conf" "$RELEASE_DIR/deapx.conf"
cp "$PROJECT_ROOT/VERSION" "$RELEASE_DIR/VERSION"
echo "  Configuration stored."

# Generate release manifest
echo "[3/4] Generating release manifest..."
MANIFEST_FILE="$RELEASE_DIR/MANIFEST"
{
    echo "Release Manifest"
    echo "================"
    echo "Project: $NAME"
    echo "Version: $VERSION"
    echo "Debian Release: $DEBIAN_RELEASE"
    echo "Architecture: $ARCH"
    echo "Profile: $PROFILE"
    echo "Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    echo "Build System Revision: A"
    echo ""
    echo "Components:"
    echo "- live-build base system"
    echo "- Debian $DEBIAN_RELEASE"
    echo "- Architecture: $ARCH"
    echo "- Profile: $PROFILE"
} > "$MANIFEST_FILE"
echo "  Manifest created."

# Create release info
echo "[4/4] Finalizing release preparation..."
RELEASE_INFO="$RELEASE_DIR/RELEASE_INFO"
{
    echo "DeapX $VERSION ($DEBIAN_RELEASE - $ARCH)"
    echo "Profile: $PROFILE"
    echo "Released: $(date -u +"%Y-%m-%d")"
} > "$RELEASE_INFO"
echo "  Release info created."

echo ""
echo "========================================="
echo "Release preparation completed!"
echo "========================================="
echo "Release directory: $RELEASE_DIR"
echo ""
echo "Files prepared:"
echo "  - deapx.conf"
echo "  - VERSION"
echo "  - MANIFEST"
echo "  - RELEASE_INFO"
echo "========================================="

exit 0