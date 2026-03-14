# Discover available services by scanning runtime/*/docker-compose.yml
function sail-service-discovery {
    sail-runtime-check

    for service_compose in "$LARAVEL_RUNTIME_DIRECTORY"/runtime/*/docker-compose.yml; do
        if [ -f "$service_compose" ]; then
            # Exclude the sail directory (not a service)
            local dir_name
            dir_name=$(basename "$(dirname "$service_compose")")
            [ "$dir_name" != "sail" ] && echo "$dir_name"
        fi
    done
}

# Return colon-separated compose file paths for the given site directory's services.
# Reads from .sail-services if present, otherwise falls back to all discovered services.
function sail-service-compose-files {
    sail-runtime-check

    local site_directory="$1"
    local services=()

    if [ -n "$site_directory" ] && [ -f "$site_directory/.sail-services" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [ -n "$line" ] && services+=("$line")
        done < "$site_directory/.sail-services"
    else
        # Backwards compat: no .sail-services means include all services
        while IFS= read -r line; do
            services+=("$line")
        done < <(sail-service-discovery)
    fi

    local result=""
    for service in "${services[@]}"; do
        local compose_file="$LARAVEL_RUNTIME_DIRECTORY/runtime/$service/docker-compose.yml"
        if [ -f "$compose_file" ]; then
            result="$result:$compose_file"
        fi
    done

    echo "$result"
}
