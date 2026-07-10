# DeapX OS Build Requirements

## Build Host
| Requirement | Minimum |
|-------------|---------|
| OS          | Debian 13 (Trixie) Stable (recommended) |
| Architecture| amd64 |
| Disk space  | 20 GB free |
| RAM         | 4 GB (8 GB recommended) |
| Network     | Required for package download |
| Privileges  | root (sudo) |

## Required Packages
Installed automatically by `scripts/check-deps.sh`:
- live-build
- debootstrap
- squashfs-tools
- genisoimage / xorriso
- syslinux / isolinux
- grub-efi-amd64-bin / grub-pc-bin
- mtools, dosfstools, rsync, wget, curl

## Target Output
- `deapx-os-trixie-amd64.iso` — hybrid bootable ISO (UEFI + legacy BIOS)
