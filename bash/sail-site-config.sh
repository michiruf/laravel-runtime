# shellcheck disable=SC2155

# Resolve and compile the compose configuration for the current site.
# For merge-based sites: compiles all compose files into a single
# docker-compose.config.yml and echoes its path.
# For full custom compose sites: echoes the existing compose file path.
function sail-site-config {
    local site_directory=$(sail-site-directory "$(pwd)")
    if [ -z "$site_directory" ]; then
        return 1
    fi

    local service_compose_files=$(sail-service-compose-files "$site_directory")

    if [ -f "$site_directory/docker-compose.override.yml" ]; then
        local compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}:$site_directory/docker-compose.override.yml"
    elif grep -q '[^[:space:]]' "$site_directory/docker-compose.yml" 2>/dev/null && \
         ! grep -qx 'services: {}' "$site_directory/docker-compose.yml" 2>/dev/null; then
        echo "$site_directory/docker-compose.yml"
        return 0
    else
        local compose_files="$site_directory/docker-compose.yml:$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}"
    fi

    # Compile merged config into a single file
    local config_file="$site_directory/docker-compose.config.yml"
    local compose_args=""
    IFS=':' read -ra files <<< "$compose_files"
    for f in "${files[@]}"; do
        compose_args="$compose_args -f $f"
    done

    docker compose "$compose_args" config > "$config_file"
    echo "$config_file"
}
