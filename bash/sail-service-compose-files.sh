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
        while IFS= read -r line; do services+=("$line"); done < <(sail-service-discovery)
    fi

    local result=""
    for service in "${services[@]}"; do
        local compose_file="$LARAVEL_RUNTIME_DIRECTORY/runtime/$service/docker-compose.yml"
        [ -f "$compose_file" ] && result="$result:$compose_file"
    done
    echo "$result"
}
