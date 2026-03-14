function sail {
    sail-runtime-check

    # Check if runtime was installed
    sail="$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail"
    if [ ! -f "$sail" ]; then
        echo "Sail is not installed. Run install.sh of the runtime first."
        return 1
    fi

    project_path="$(pwd)"

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
    site_directory=$(sail-site-directory "$project_path")
    if [ -z "$site_directory" ]; then
        echo "No site directory found for '$(basename "$project_path")'."
        echo "Run 'sail-setup' from your project directory first."
        return 1
    fi

    # Symbolic link the env file, since docker is again totally restrictive without printing errors..
    rm -f "$site_directory/.env"
    if [ -f "$project_path/.env" ]; then
        ln -s "$project_path/.env" "$site_directory/.env"
    fi

    # Resolve service compose files for this site
    local service_compose_files
    service_compose_files=$(sail-service-compose-files "$site_directory")

    # Determine compose file(s) — site directory always comes first for .env resolution
    if [ -f "$site_directory/docker-compose.override.yml" ]; then
        # Site compose + shared + services + override
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}:$site_directory/docker-compose.override.yml"
    elif grep -q '[^[:space:]]' "$site_directory/docker-compose.yml" 2>/dev/null && \
         ! grep -qx 'services: {}' "$site_directory/docker-compose.yml" 2>/dev/null; then
        # Full custom compose (more than just the minimal stub)
        compose_files="$site_directory/docker-compose.yml"
    else
        # Minimal site compose + shared + services
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}"
    fi

    # Pre-build base sail image when building
    if [[ "$1" == "build" || "$1" == "up" ]]; then
        local php_version="${PHP_VERSION:-8.4}"
        local sail_runtime="$LARAVEL_RUNTIME_DIRECTORY/vendor/laravel/sail/runtimes/$php_version"
        if [ -d "$sail_runtime" ]; then
            if [[ "$1" == "build" ]] || ! docker image inspect "sail-${php_version}/app" > /dev/null 2>&1; then
                echo "Building base sail image (PHP $php_version)..."
                docker build -t "sail-${php_version}/app" --build-arg WWWGROUP=1000 "$sail_runtime"
            fi
        fi
    fi

    # Invoke services alongside sail
    for service in "$LARAVEL_RUNTIME_DIRECTORY/services"/*/service.sh; do
        [ -f "$service" ] && bash "$service" "$@"
    done

    SAIL_FILES="$compose_files" $sail $@
}
