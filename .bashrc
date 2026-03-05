function sail {
    # Avoid autocomplete for sail, since autocomplete calls the sail function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && return

    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    project_path="$(pwd)"

    if [ -f sail ]; then
        sail="sail"
    elif [ -f vendor/bin/sail ]; then
        sail="vendor/bin/sail"
    else
        project_name=$(basename "$project_path")
        echo "There is no sail installed in this project ($project_name)"
        return 1
    fi

    site_directory=$(sail-site-directory "$project_path")
    if [ -z "$site_directory" ]; then
        echo "There is no site configured for this project (searched up from $project_path)"
        return 1
    fi

    # Check if docker-compose.yml exists
    if [ ! -f "$site_directory/docker-compose.yml" ]; then
        echo "There is no docker-compose file for this project in $site_directory/docker-compose.yml"
        return 1
    fi

    # Update the hosts file
    # This requires administrator privileges
    # When the entrypoint is PHPStorm, it needs to be started as administrator
    # When the entrypoint is Powershell, it needs to be started as administrator
    $LARAVEL_RUNTIME_DIRECTORY/provision/host/update-hosts-file.sh

    # Symbolic link the env file, since docker is again totally restrictive without printing errors..
    rm -f $site_directory/.env
    if [ -f $project_path/.env ]; then
        relative_env=$(realpath --relative-to="$site_directory" $project_path/.env)
        ln -s $relative_env $site_directory/.env
    else
        echo -e "\033[0;33mWARNING\033[0m: There is no .env file in $project_path"
    fi

    # Finally call sail to handle the command
    SAIL_FILES="$site_directory/docker-compose.yml" $sail $@
}

function sail-runtime {
    # Avoid autocomplete for sail-runtime, since autocomplete calls the sail-runtime function
    # Next line did disable the command at all
    [[ -n "$COMP_LINE" ]] && return

    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    (cd $LARAVEL_RUNTIME_DIRECTORY/services/local-proxy && docker-compose $@)

    if [ "$LARAVEL_RUNTIME_LLM_PROXY_ENABLED" = "true" ]; then
        (cd $LARAVEL_RUNTIME_DIRECTORY/services/llm-proxy && docker-compose $@)
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
        if [ -f "$candidate/docker-compose.yml" ]; then
            echo "$candidate"
            return 0
        fi

        search_path=$(dirname "$search_path")
    done

    return 1
}
