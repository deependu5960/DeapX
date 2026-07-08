#!/usr/bin/env bash
# -*- coding: utf-8 -*-
#
# Deap X Operating System - Clean Script
# Version: 1.0.0
# Description: Clean build artifacts and cache
#

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

clean_all() {
    log_info "Cleaning all build artifacts..."
    
    cd "${SCRIPT_DIR}"
    
    # Clean live-build artifacts
    if command -v lb &> /dev/null; then
        lb clean --purge 2>/dev/null || true
    fi
    
    # Remove build directories
    local directories=(
        "config"
        "cache"
        "output"
    )
    
    for dir in "${directories[@]}"; do
        if [[ -d "${dir}" ]]; then
            rm -rf "${dir}"
            log_info "Removed: ${dir}/"
        fi
    done
    
    # Remove build logs
    find "${SCRIPT_DIR}" -maxdepth 1 -name "*.log" -delete 2>/dev/null || true
    
    log_info "Cleanup completed"
}

clean_cache() {
    log_info "Cleaning cache only..."
    
    cd "${SCRIPT_DIR}"
    
    if [[ -d "cache" ]]; then
        rm -rf cache/*
        log_info "Cache cleared"
    fi
}

clean_output() {
    log_info "Cleaning output directory..."
    
    cd "${SCRIPT_DIR}"
    
    if [[ -d "output" ]]; then
        rm -rf output/*
        log_info "Output directory cleared"
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [OPTION]

Clean Deap X build artifacts.

Options:
  --all       Clean all artifacts (config, cache, output)
  --cache     Clean only cache directory
  --output    Clean only output directory
  --help      Show this help message

Examples:
  $0 --all          # Complete clean
  $0 --cache        # Clean only cache
  $0 --output       # Clean only output
EOF
}

main() {
    case "${1:---all}" in
        --all)
            clean_all
            ;;
        --cache)
            clean_cache
            ;;
        --output)
            clean_output
            ;;
        --help)
            show_usage
            ;;
        *)
            log_error "Unknown option: ${1:-}"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"