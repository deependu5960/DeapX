#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "DeapX Build System - Verification"
echo "========================================="
echo ""

ERRORS=0

# Check VERSION file
echo "[1] Checking VERSION file..."
if [ -f "$PROJECT_ROOT/VERSION" ]; then
    echo "  VERSION: $(cat "$PROJECT_ROOT/VERSION")"
else
    echo "  ERROR: VERSION file missing!"
    ERRORS=$((ERRORS + 1))
fi

# Check configuration
echo "[2] Checking configuration..."
if [ -f "$PROJECT_ROOT/config/deapx.conf" ]; then
    echo "  Configuration file present."
    source "$PROJECT_ROOT/config/deapx.conf"
    
    if [ -n "$NAME" ] && [ -n "$VERSION" ] && [ -n "$DEBIAN_RELEASE" ] && [ -n "$ARCH" ] && [ -n "$PROFILE" ]; then
        echo "  NAME=$NAME"
        echo "  VERSION=$VERSION"
        echo "  DEBIAN_RELEASE=$DEBIAN_RELEASE"
        echo "  ARCH=$ARCH"
        echo "  PROFILE=$PROFILE"
    else
        echo "  ERROR: Missing required variables in config/deapx.conf"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ERROR: config/deapx.conf missing!"
    ERRORS=$((ERRORS + 1))
fi

# Check build scripts
echo "[3] Checking build scripts..."
BUILD_SCRIPTS=("build.sh" "clean.sh" "verify.sh" "release.sh")
for script in "${BUILD_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/build/$script" ]; then
        if [ -x "$PROJECT_ROOT/build/$script" ]; then
            echo "  $script: OK (executable)"
        else
            echo "  $script: OK (not executable - fixing)"
            chmod +x "$PROJECT_ROOT/build/$script"
        fi
    else
        echo "  $script: MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check dependencies
echo "[4] Checking build dependencies..."
DEPENDENCIES=("lb" "debootstrap" "xorriso" "rsync")
for dep in "${DEPENDENCIES[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "  $dep: installed"
    else
        echo "  $dep: MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check live-build structure
echo "[5] Checking live-build structure..."
LB_DIRS=("auto" "config" "hooks" "includes" "package-lists")
for dir in "${LB_DIRS[@]}"; do
    if [ -d "$PROJECT_ROOT/live-build/$dir" ]; then
        echo "  live-build/$dir: OK"
    else
        echo "  live-build/$dir: MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check profile directories
echo "[6] Checking profile directories..."
PROFILES=("developer" "release" "debug")
for profile in "${PROFILES[@]}"; do
    if [ -d "$PROJECT_ROOT/live-build/profiles/$profile" ]; then
        echo "  live-build/profiles/$profile: OK"
    else
        echo "  live-build/profiles/$profile: MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check project directories
echo "[7] Checking project directories..."
PROJECT_DIRS=("branding" "boot" "login" "desktop" "applications" "packages" "assets" "scripts" "iso" "testing" "releases" "future")
for dir in "${PROJECT_DIRS[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        echo "  $dir: OK"
    else
        echo "  $dir: MISSING"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "========================================="
    echo "VERIFICATION PASSED"
    echo "========================================="
    exit 0
else
    echo "========================================="
    echo "VERIFICATION FAILED - $ERRORS error(s) found"
    echo "========================================="
    exit 1
fi