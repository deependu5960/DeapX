# Deap X Operating System

**Version:** 1.0.0  
**Distribution:** Debian GNU/Linux 12 (Bookworm)  
**Architecture:** amd64  
**Build System:** live-build  
**Default Browser:** Brave

---

## Overview

Deap X is a professional Debian-based Linux distribution built with live-build. It provides a modular architecture for creating custom Debian Live ISO images with Brave Browser as the default web browser for enhanced privacy and security.

## Features

- **Modular Architecture**: Organized build system with clear separation of components
- **Multiple Profiles**: Minimal, Standard, and Development profiles
- **Custom Overlays**: Easy customization through overlay files
- **Package Management**: Organized package lists by category
- **Production-Quality**: Industry-standard build practices and shell scripting
- **Automated Build**: Single-command ISO generation
- **Checksum Verification**: SHA256 and MD5 checksums for security
- **Brave Browser**: Pre-installed and configured as default browser

---

## Quick Start

### Prerequisites

**Install dependencies:**

```bash
sudo apt-get update
sudo apt-get install -y live-build debootstrap xorriso \
    squashfs-tools cpio gzip rsync wget curl git