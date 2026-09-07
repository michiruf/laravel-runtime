#!/usr/bin/env bash

PROJECT_PATH="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_PATH")
export PROJECT_NAME
export PROJECT_PATH

# Set project vars for the shared docker-compose
if [ -f "$LARAVEL_RUNTIME_DIRECTORY/.env" ]; then
    set -a
    source "$LARAVEL_RUNTIME_DIRECTORY/.env"
    set +a
fi

# Allow a site to pin its own PHP version, overriding the runtime default
site_directory=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/site-directory.sh" 2>/dev/null)
if [ -n "$site_directory" ] && [ -s "$site_directory/.php-version" ]; then
    PHP_VERSION=$(<"$site_directory/.php-version")
fi
export PHP_VERSION
