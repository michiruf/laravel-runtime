# shellcheck disable=SC2155

function sail {
    sail-runtime-check

    local project_path="$(pwd)"

    # Source global runtime defaults
    if [ -f "$LARAVEL_RUNTIME_DIRECTORY/.env" ]; then
        set -a
        source "$LARAVEL_RUNTIME_DIRECTORY/.env"
        set +a
    fi

    # Set project vars for the shared docker-compose
    export PROJECT_NAME=$(basename "$project_path")
    export PROJECT_PATH="$project_path"

    # Require a site directory
    local site_directory=$(sail-site-directory "$project_path")
    if [ -z "$site_directory" ]; then
        echo "No site directory found for '$(basename "$project_path")'."
        echo "Run 'sail-setup' from your project directory first."
        return 1
    fi

    # Symbolic link the env file, since docker is totally restrictive without printing errors
    rm -f "$site_directory/.env"
    [ -f "$project_path/.env" ] && ln -s "$project_path/.env" "$site_directory/.env"

    # Resolve service compose files for this site
    local service_compose_files=$(sail-service-compose-files "$site_directory")

    # Determine compose file(s) — site directory always comes first for .env resolution
    local compose_files
    if [ -f "$site_directory/docker-compose.override.yml" ]; then
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}:$site_directory/docker-compose.override.yml"
    elif grep -q '[^[:space:]]' "$site_directory/docker-compose.yml" 2>/dev/null && \
         ! grep -qx 'services: {}' "$site_directory/docker-compose.yml" 2>/dev/null; then
        compose_files="$site_directory/docker-compose.yml"
    else
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}"
    fi

    # Pre-build base sail image when building
    if [[ "$1" == "build" || "$1" == "up" ]]; then
        local php_version="${PHP_VERSION:-8.4}"
        local sail_runtime="$LARAVEL_RUNTIME_DIRECTORY/vendor/laravel/sail/runtimes/$php_version"
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

    SAIL_FILES="$compose_files" "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" "$@"
}
