#!/usr/bin/env bash

# Invoke services alongside sail (only for docker compose commands)
if docker compose "$1" --help &>/dev/null; then
    for service in "$LARAVEL_RUNTIME_DIRECTORY/services"/*/service.sh; do
        [ -f "$service" ] && bash "$service" "$@"
    done
fi
