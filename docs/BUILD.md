# DeapX OS Build Guide

## Quick Build
```bash
git clone <repository-url> DeapX-OS
cd DeapX-OS
sudo ./build.sh
```

## Output
On success:
`deapx-os-trixie-amd64.iso`

## Build Steps (internal)
1. `scripts/setup-perms.sh` — ensures correct script permissions
2. `scripts/check-deps.sh` — verify and install host packages
3. `scripts/clean.sh` — remove prior artifacts safely
4. `scripts/configure.sh` — configure live-build settings and environment exports
5. `lb build` — run the live-build pipeline
6. `scripts/verify-iso.sh` — validate output ISO integrity

## Manual Stages
```bash
sudo ./scripts/setup-perms.sh
sudo ./scripts/check-deps.sh
sudo ./scripts/clean.sh
sudo ./scripts/configure.sh
sudo lb build
```

## Logs
Build output is saved to `build.log`.
