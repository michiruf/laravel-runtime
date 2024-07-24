function sail {
    # Requires $LARAVEL_RUNTIME_DIRECTORY to be set
    if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
        echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
        return 1
    fi

    project_path="$(pwd)"
    project_name=$(basename "$project_path")

    $LARAVEL_RUNTIME_DIRECTORY/update-hosts-file.sh

    if [ -f sail ]; then
        sail="sail"
    elif [ -f vendor/bin/sail ]; then
        sail="vendor/bin/sail"
    else
        echo "There is no sail installed in this directory ($project_path)"
        return 1
    fi

    # Symbolic link the env file, since docker is again totally restrictive without printing errors..
    rm -f $LARAVEL_RUNTIME_DIRECTORY/sites/$project_name/.env
    if [ -f .env ]; then
        ln -s $project_path/.env $LARAVEL_RUNTIME_DIRECTORY/sites/$project_name/.env
    fi

    SAIL_FILES="$LARAVEL_RUNTIME_DIRECTORY/sites/$project_name/docker-compose.yml" $sail $@
}
