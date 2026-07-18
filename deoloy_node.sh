#!/usr/bin/env bash
# deploy-node.sh - Localized Deployment Setup for aura-moby Nodes
set -euo pipefail

# 1. Environment Configurations
export GO_VERSION_REQ="1.21"
export ZIG_VERSION_REQ="0.11"
export TARGET_DIR="/usr/local/bin"
export INIT_SQL_PATH="./—01_init.sql"

echo "=== [1/4] Validating Host Toolchains ==="
if ! command -v go &> /dev/null || [[ "$(go version | awk '{print $3}')" < "go$GO_VERSION_REQ" ]]; then
    echo "CRITICAL: Go Toolchain >= $GO_VERSION_REQ is required." && exit 1
fi
if ! command -v zig &> /dev/null || [[ "$(zig version)" < "$ZIG_VERSION_REQ" ]]; then
    echo "CRITICAL: Zig Compiler >= $ZIG_VERSION_REQ is required." && exit 1
fi

echo "=== [2/4] Initializing Environment Profiles ==="
chmod +x bash.sh bash.zsh
./bash.sh

echo "=== [3/4] Compiling Standalone Targets via Zig ==="
# Building optimized native standalone targets using the localized system harness
zig build --summary all -Doptimize=ReleaseFast

echo "=== [4/4] Bootstrapping Localized Data Schemas ==="
if [ -f "$INIT_SQL_PATH" ]; then
    echo "Initializing localized transactional schema boundaries..."
    # Simulates passing the init schema straight down to the node storage framework
    cat "$INIT_SQL_PATH" > ./storage/local_schema_bootstrap.sql
else
    echo "WARNING: Regional setup script —01_init.sql not found. Skipping schema setup."
fi

echo "=== Success: aura-moby daemon compiled and prepared for runtime execution ==="
