function sail {
    # Avoid autocomplete for sail, since autocomplete calls the sail function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && return

    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

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

    # Point docker-compose to the project's .env for variable substitution
    if [ -f "$project_path/.env" ]; then
        export COMPOSE_ENV_FILE="$project_path/.env"
    fi

    # Set project vars for the shared docker-compose
    export PROJECT_NAME=$(basename "$project_path")
    export PROJECT_PATH="$project_path"

    # Update the hosts file (requires admin privileges for the WSL terminal)
    if [ "$WSL_UPDATE_HOSTS_FILE" = "true" ]; then
        $LARAVEL_RUNTIME_DIRECTORY/wsl/update-hosts-file.sh
    fi

    # Determine compose file(s)
    site_directory=$(sail-site-directory "$project_path")
    if [ -n "$site_directory" ] && [ -f "$site_directory/docker-compose.yml" ]; then
        # Full custom compose
        compose_files="$site_directory/docker-compose.yml"
        # Symlink .env for docker-compose
        rm -f "$site_directory/.env"
        if [ -f "$project_path/.env" ]; then
            ln -s "$(realpath --relative-to="$site_directory" "$project_path/.env")" "$site_directory/.env"
        fi
    elif [ -n "$site_directory" ] && [ -f "$site_directory/docker-compose.override.yml" ]; then
        # Shared + override
        compose_files="$LARAVEL_RUNTIME_DIRECTORY/runtime/docker-compose.yml:$site_directory/docker-compose.override.yml"
    else
        # Shared only
        compose_files="$LARAVEL_RUNTIME_DIRECTORY/runtime/docker-compose.yml"
    fi

    # Pre-build base Sail image when building
    if [[ "$1" == "build" || "$1" == "up" ]]; then
        local php_version="${PHP_VERSION:-8.4}"
        local sail_runtime="$LARAVEL_RUNTIME_DIRECTORY/vendor/laravel/sail/runtimes/$php_version"
        if [ -d "$sail_runtime" ]; then
            echo "Building base Sail image (PHP $php_version)..."
            docker build -t "sail-${php_version}/app" --build-arg WWWGROUP=1000 "$sail_runtime"
        fi
    fi

    # Automatically manage services alongside sail
    if [[ "$1" == "up" ]]; then
        sail-services up -d
    elif [[ "$1" == "down" || "$1" == "stop" ]]; then
        sail-services "$1"
    fi

    SAIL_FILES="$compose_files" $sail $@
}

function sail-services {
    # Avoid autocomplete for sail, since autocomplete calls the sail function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && return

    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    # Source .env for service flags
    if [ -f "$LARAVEL_RUNTIME_DIRECTORY/.env" ]; then
        set -a
        source "$LARAVEL_RUNTIME_DIRECTORY/.env"
        set +a
    fi

    if [ "$SERVICE_LOCAL_PROXY" = "true" ]; then
        (cd "$LARAVEL_RUNTIME_DIRECTORY/services/local-proxy" && docker-compose "$@")
    fi

    if [ "$SERVICE_LLM_PROXY" = "true" ]; then
        (cd "$LARAVEL_RUNTIME_DIRECTORY/services/llm-proxy" && docker-compose "$@")
    fi
}

# Resolve the site directory for the current project by walking upward from
# the given path, building progressively longer relative paths and checking
# for a match under $LARAVEL_RUNTIME_DIRECTORY/sites/.
# e.g. for /home/app/my/sub/project, checks:
#   sites/project -> sites/sub/project -> sites/my/sub/project
function sail-site-directory {
    # Avoid autocomplete for sail, since autocomplete calls the sail function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && return

    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

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
