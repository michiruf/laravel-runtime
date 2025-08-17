function sail {
    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    project_path="$(pwd)"
    project_name=$(basename "$project_path")
    site_directory="$LARAVEL_RUNTIME_DIRECTORY/sites/$project_name"

    if [ -f sail ]; then
        sail="sail"
    elif [ -f vendor/bin/sail ]; then
        sail="vendor/bin/sail"
    else
        echo "There is no sail installed in this project ($project_name)"
        return 1
    fi

    # Check if project exists
    if [ ! -d $site_directory ]; then
        echo "There is no site configured for this project in $site_directory"
        return 1
    fi

    # Check if docker-compose.yml exists
    if [ ! -f $site_directory/docker-compose.yml ]; then
        echo "There is no docker-compose file for this project in $site_directory/docker-compose.yml"
        return 1
    fi

    # Update the hosts file
    # This requires administrator privileges
    # When the entrypoint is PHPStorm, it needs to be started as administrator
    # When the entrypoint is Powershell, it needs to be started as administrator
    $LARAVEL_RUNTIME_DIRECTORY/update-hosts-file.sh

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
    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    (cd $LARAVEL_RUNTIME_DIRECTORY/services/local-proxy && docker-compose $@)
    (cd $LARAVEL_RUNTIME_DIRECTORY/services/llm-proxy && docker-compose $@)
}
