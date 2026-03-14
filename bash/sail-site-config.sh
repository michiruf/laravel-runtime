# shellcheck disable=SC2155

# Resolve and compile the compose configuration for the current site.
# For sites with docker-compose.custom.yml: echoes that path (full replacement).
# For merge-based sites: compiles all compose files into docker-compose.yml.
function sail-site-config {
    local site_directory=$(sail-site-directory "$(pwd)")
    if [ -z "$site_directory" ]; then
        return 1
    fi

    # Full custom compose — use as-is
    if [ -f "$site_directory/docker-compose.custom.yml" ]; then
        echo "$site_directory/docker-compose.custom.yml"
        return 0
    fi

    # Merge mode: runtime + services + optional override
    local service_compose_files=$(sail-service-compose-files "$site_directory")
    local compose_files="$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml${service_compose_files}"

    if [ -f "$site_directory/docker-compose.override.yml" ]; then
        compose_files="$compose_files:$site_directory/docker-compose.override.yml"
    fi

    # Compile merged config into a single file
    local config_file="$site_directory/docker-compose.yml"
    local compose_cmd=(docker compose --project-directory "$site_directory")
    IFS=':' read -ra files <<< "$compose_files"
    for f in "${files[@]}"; do
        compose_cmd+=(-f "$f")
    done

    "${compose_cmd[@]}" config > "$config_file"
    echo "$config_file"
}
