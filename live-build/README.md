# live-build Directory

This directory contains the live-build configuration for DeapX.

## Structure

- **auto/** - Automated build scripts and configurations
- **config/** - Live-build configuration files
- **hooks/** - Build hooks and custom scripts
- **includes/** - Files to include in the live system
- **package-lists/** - Package list definitions
- **profiles/** - Build profiles for different use cases

## Profiles

- **developer/** - Development and testing profile
- **release/** - Production release profile
- **debug/** - Debug and troubleshooting profile

## Usage

The build system uses this directory structure to generate DeapX ISO images.
Configuration is managed through the main build scripts in the `build/` directory.