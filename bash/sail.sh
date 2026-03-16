#!/usr/bin/env bash

source "$LARAVEL_RUNTIME_DIRECTORY/bash/env.sh"

# Resolve and compile compose configuration
compose_file=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/site-compose.sh") || exit 1

# Pre-build base sail image when building
bash "$LARAVEL_RUNTIME_DIRECTORY/bash/build-base.sh" "$@" || exit 1

# Invoke services alongside sail
bash "$LARAVEL_RUNTIME_DIRECTORY/bash/service-start.sh" "$@" || exit 1

# Remove orphan containers by default for up/down
args=("$@")
if [[ "$1" == "up" || "$1" == "down" ]]; then
    args+=("--remove-orphans")
fi

SAIL_FILES="$compose_file" "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" "${args[@]}"
