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

    # Determine compose file(s) — site directory always comes first for .env resolution
    if [ -f "$site_directory/docker-compose.override.yml" ]; then
        # Site compose + shared + override
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/docker-compose.yml:$site_directory/docker-compose.override.yml"
    elif grep -q '[^[:space:]]' "$site_directory/docker-compose.yml" 2>/dev/null && \
         ! grep -qx 'services: {}' "$site_directory/docker-compose.yml" 2>/dev/null; then
        # Full custom compose (more than just the minimal stub)
        compose_files="$site_directory/docker-compose.yml"
    else
        # Minimal site compose + shared
        compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/docker-compose.yml"
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

# Resolve the site directory for the current project by walking upward from
# the given path, building progressively longer relative paths and checking
# for a match under $LARAVEL_RUNTIME_DIRECTORY/sites/.
# e.g. for /home/app/my/sub/project, checks:
#   sites/project -> sites/sub/project -> sites/my/sub/project
function sail-site-directory {
    sail-runtime-check

    local search_path="${1:-$(pwd)}"
    local relative_path=""

    while [ "$search_path" != "/" ]; do
        local segment=$(basename "$search_path")

        if [ -z "$relative_path" ]; then
            relative_path="$segment"
        else
            relative_path="$segment/$relative_path"
        fi

        local candidate="$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path"
        if [ -d "$candidate" ]; then
            echo "$candidate"
            return 0
        fi

        search_path=$(dirname "$search_path")
    done

    return 1
}

function sail-setup {
    sail-runtime-check

    local project_path="$(pwd)"

    # Build path options by walking up from current directory
    local options=()
    local search_path="$project_path"
    local relative_path=""

    while [ "$search_path" != "/" ]; do
        local segment=$(basename "$search_path")

        if [ -z "$relative_path" ]; then
            relative_path="$segment"
        else
            relative_path="$segment/$relative_path"
        fi

        options+=("$relative_path")
        search_path=$(dirname "$search_path")
    done

    # Present options to user
    echo "Select site path:"
    for i in "${!options[@]}"; do
        echo "  $((i + 1))) ${options[$i]}"
    done

    local choice
    read -rp "Choice [1]: " choice
    choice="${choice:-1}"

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#options[@]}" ]; then
        echo "Invalid choice."
        return 1
    fi

    local site_directory="$LARAVEL_RUNTIME_DIRECTORY/sites/${options[$((choice - 1))]}"

    mkdir -p "$site_directory"

    # Write minimal docker-compose.yml for .env resolution
    cat > "$site_directory/docker-compose.yml" <<'COMPOSE'
services: {}
COMPOSE

    # Symlink project .env into site directory
    rm -f "$site_directory/.env"
    if [ -f "$project_path/.env" ]; then
        ln -s "$project_path/.env" "$site_directory/.env"
    fi

    local relative="${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}"
    echo "Created $relative/"
}

function sail-runtime-check {
    # Avoid autocomplete for sail, since autocomplete calls the sail function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && exit 1

    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        exit 1
    fi
}
