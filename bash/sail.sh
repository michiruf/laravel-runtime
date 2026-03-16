#!/usr/bin/env bash

PROJECT_PATH="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_PATH")

# Set project vars for the shared docker-compose
if [ -f "$LARAVEL_RUNTIME_DIRECTORY/.env" ]; then
    set -a
    source "$LARAVEL_RUNTIME_DIRECTORY/.env"
    set +a
fi
export PROJECT_NAME
export PROJECT_PATH

# Resolve and compile compose configuration
compose_file=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-site-compose.sh") || exit 1

# Pre-build base sail image when building
bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-build-base.sh" "$@" || exit 1

# Invoke services alongside sail
bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-service-start.sh" "$@" || exit 1

# Remove orphan containers by default for up/down
args=("$@")
if [[ "$1" == "up" || "$1" == "down" ]]; then
    args+=("--remove-orphans")
fi

SAIL_FILES="$compose_file" "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" "${args[@]}"
