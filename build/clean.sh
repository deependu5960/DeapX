#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "DeapX Build System - Clean"
echo "========================================="
echo ""

echo "Cleaning build artifacts..."

if [ -d "$PROJECT_ROOT/live-build/config" ]; then
    cd "$PROJECT_ROOT/live-build"
    if [ -f "Makefile" ] || [ -d ".build" ]; then
        echo "  Running lb clean..."
        lb clean 2>/dev/null || echo "  Live-build clean completed with warnings."
    fi
    cd "$PROJECT_ROOT"
fi

echo "  Removing temporary files..."
find "$PROJECT_ROOT" -name "*.log" -type f -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name ".build" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -name "chroot" -type d -exec rm -rf {} + 2>/dev/null || true
find "$PROJECT_ROOT" -name "cache" -type d -exec rm -rf {} + 2>/dev/null || true

if [ -d "$PROJECT_ROOT/iso" ]; then
    echo "  Cleaning ISO directory..."
    rm -rf "$PROJECT_ROOT/iso/"* 2>/dev/null || true
fi

echo ""
echo "Clean completed."
echo "========================================="

exit 0