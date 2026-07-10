# DeapX OS

Production live operating system based on **Debian 13 (Trixie) Stable**, built with `live-build`.

## Features (Foundation Release)
- Bootable hybrid ISO (UEFI + legacy BIOS)
- KDE Plasma desktop environment
- SDDM display manager (Wayland)
- Plymouth boot splash
- GRUB bootloader
- Live session with persistence-ready infrastructure

## Requirements
- Debian 13 (Trixie) amd64 build host (recommended)
- 20 GB free disk space
- 4 GB RAM (8 GB recommended)
- Root access
- Internet connection

See [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) for details.

## Build
```bash
sudo ./build.sh
```
Output: `deapx-os-trixie-amd64.iso`

### Live Session
| Field | Value |
|-------|-------|
| Username | `deapx` |
| Password | `deapx` |

## Project Structure
```
DeapX-OS/
├── build.sh              # One-command build
├── config/build.conf     # Build configuration
├── auto/                 # live-build auto scripts
├── hooks/                # Chroot and live hooks
├── includes.chroot/      # Rootfs file overlays
├── package-lists/        # Package manifests
├── scripts/              # Build automation
├── branding/             # Brand assets
├── grub/ plymouth/ sddm/ # Component dirs
└── docs/                 # Documentation
```

## Documentation
- [Build Guide](docs/BUILD.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Requirements](docs/REQUIREMENTS.md)

## License
Components inherit licenses from Debian and respective upstream projects. DeapX OS build system: MIT License.
