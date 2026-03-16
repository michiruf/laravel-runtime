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
