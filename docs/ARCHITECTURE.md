# DeapX OS Architecture

## Overview
DeapX OS is a Debian 13 (Trixie) Stable live system built with `live-build`, shipping a customized KDE Plasma desktop.

## Repository Layout
| Path | Purpose |
|------|---------|
| `build.sh` | Single-command build entry |
| `config/build.conf` | Central build variables |
| `auto/` | live-build auto hooks |
| `hooks/normal/` | Chroot customization (numbered) |
| `hooks/live/` | Live image stage hooks |
| `includes.chroot/` | Files copied into target rootfs |
| `package-lists/` | APT package manifests |
| `scripts/` | Modular build automation |
| `branding/` | Brand assets (future) |
| `grub/`, `plymouth/`, `sddm/` | Component customization dirs |
| `themes/`, `wallpapers/` | Reserved for future releases |

## Build Pipeline
```
build.sh
├── setup-perms.sh → apply execution flags
├── check-deps.sh  → host package validation
├── clean.sh       → safe chroot unmounting and artifact purge
├── configure.sh   → dynamic build.env export & lb config
└── lb build
    ├── bootstrap  → debootstrap trixie
    ├── chroot     → packages + hooks
    ├── binary     → squashfs + ISO
    └── iso-hybrid → final bootable image
```

## Target System
- **Init**: systemd
- **Display manager**: SDDM (Wayland default)
- **Desktop**: KDE Plasma
- **Boot splash**: Plymouth (spinner)
- **Bootloader**: GRUB EFI hybrid
- **Live user**: `deapx` / `deapx` (configured with passwordless sudo)

## Extension Points
Future customization hooks:
- `branding/` — logos, icons, metadata
- `themes/` — SDDM / Plasma themes
- `plymouth/` — custom boot splash
- `grub/` — boot menu theming
- `wallpapers/` — desktop backgrounds
- `package-lists/deapx.list.chroot` — additional packages
