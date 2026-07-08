#!/bin/bash
# Deap X - Pre-Build Script
# Executed before live-build begins

pre_build() {
    echo "Deap X Pre-Build: Preparing environment"
    
    mkdir -p "${SCRIPT_DIR}/config/hooks/normal"
    mkdir -p "${SCRIPT_DIR}/config/hooks/live"
    mkdir -p "${SCRIPT_DIR}/config/chroot_local-includes/usr/share/keyrings/"
    
    echo "Downloading Brave Browser GPG key..."
    curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
        > "${SCRIPT_DIR}/config/chroot_local-includes/usr/share/keyrings/brave-browser-archive-keyring.gpg"
    
    mkdir -p "${SCRIPT_DIR}/config/chroot_local-includes/etc/apt/sources.list.d/"
    cat > "${SCRIPT_DIR}/config/chroot_local-includes/etc/apt/sources.list.d/brave-browser-release.list" << 'BRAVE_EOF'
deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main
BRAVE_EOF
    
    echo "Deap X Pre-Build completed"
}

export -f pre_build