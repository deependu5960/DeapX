#!/bin/bash
# Deap X - Chroot Pre-Install Script
# Executed inside chroot before package installation

set -e

echo "Deap X: Running chroot pre-install hooks"

# Update package cache
apt-get update

# Install curl if not already installed
apt-get install -y curl gnupg

echo "Deap X: Chroot pre-install hooks completed"