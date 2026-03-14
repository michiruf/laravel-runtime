#!/usr/bin/env bash
# shellcheck disable=SC2155

project_path="$(pwd)"

# Require a site directory
site_directory=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-site-directory.sh" "$project_path")
if [ -z "$site_directory" ]; then
    echo "No site directory found for '$(basename "$project_path")'."
    echo "Run 'sail-setup' from your project directory first."
    exit 1
fi

# Set project vars for the shared docker-compose
if [ -f "$LARAVEL_RUNTIME_DIRECTORY/.env" ]; then
    set -a
    source "$LARAVEL_RUNTIME_DIRECTORY/.env"
    set +a
fi
export PROJECT_NAME=$(basename "$project_path")
export PROJECT_PATH="$project_path"

# Resolve and compile compose configuration
compose_file=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-site-compose.sh")
if [ -z "$compose_file" ]; then
    echo "Failed to resolve compose configuration."
    exit 1
fi

# Pre-build base sail image when building
if [[ "$1" == "build" || "$1" == "up" ]]; then
    php_version="${PHP_VERSION:-8.4}"
    sail_runtime="$LARAVEL_RUNTIME_DIRECTORY/vendor/laravel/sail/runtimes/$php_version"
    if [ -d "$sail_runtime" ] && { [[ "$1" == "build" ]] || ! docker image inspect "sail-${php_version}/app" > /dev/null 2>&1; }; then
        echo "Building base sail image (PHP $php_version)..."
        docker build -t "sail-${php_version}/app" --build-arg WWWGROUP=1000 "$sail_runtime"
    fi
fi

# Invoke services alongside sail (only for docker compose commands)
if docker compose "$1" --help &>/dev/null; then
    for service in "$LARAVEL_RUNTIME_DIRECTORY/services"/*/service.sh; do
        [ -f "$service" ] && bash "$service" "$@"
    done
fi

# Remove orphan containers by default for up/down
args=("$@")
if [[ "$1" == "up" || "$1" == "down" ]]; then
    args+=("--remove-orphans")
fi

SAIL_FILES="$compose_file" "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" "${args[@]}"
