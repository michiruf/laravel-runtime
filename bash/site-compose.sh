#!/usr/bin/env bash

# Return colon-separated compose file paths for the given site directory's services.
# Reads from .sail-services if present, otherwise falls back to all discovered services.
# shellcheck disable=SC2155
resolve_compose_files() {
    local site_directory="$1"
    local services=()

    if [ -n "$site_directory" ] && [ -f "$site_directory/.sail-services" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [ -n "$line" ] && services+=("$line")
        done < "$site_directory/.sail-services"
    else
        while IFS= read -r line; do services+=("$line"); done < <(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/runtime-discovery.sh")
    fi

    local result="$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml"

    # Auto-discover feature compose files in any runtime subdirectory
    # Convention: runtime/{service}/{feature}/docker-compose.yml
    # Included when env var {SERVICE}_{FEATURE}=true (dashes become underscores, uppercased)
    # Example: runtime/sail/install-claude-code/docker-compose.yml → SAIL_INSTALL_CLAUDE_CODE
    # Example: runtime/mysql/create-test-database/docker-compose.yml → MYSQL_CREATE_TEST_DATABASE
    for feature_compose in "$LARAVEL_RUNTIME_DIRECTORY"/runtime/*/*/docker-compose.yml; do
        [ -f "$feature_compose" ] || continue
        local feature=$(basename "$(dirname "$feature_compose")")
        local dir_name=$(basename "$(dirname "$(dirname "$feature_compose")")")
        local env_var="$(echo "${dir_name}_${feature}" | tr '[:lower:]-' '[:upper:]_')"
        [[ " sail ${services[*]} " != *" $dir_name "* ]] && continue
        [ "${!env_var}" = "true" ] && result="$result:$feature_compose"
    done

    for service in "${services[@]}"; do
        local compose_file="$LARAVEL_RUNTIME_DIRECTORY/runtime/$service/docker-compose.yml"
        [ -f "$compose_file" ] && result="$result:$compose_file"
    done
    echo "$result"
}


# Resolve and compile the compose configuration for the current site.
# For sites with docker-compose.custom.yml: echoes that path (full replacement).
# For merge-based sites: compiles all compose files into docker-compose.yml.

site_directory=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/site-directory.sh") || exit 1

# Full custom compose — symlink project .env and use as-is
if [ -f "$site_directory/docker-compose.custom.yml" ]; then
    rm -f "$site_directory/.env"
    [ -f "$(pwd)/.env" ] && ln -sr "$(pwd)/.env" "$site_directory/.env"
    echo "$site_directory/docker-compose.custom.yml"
    exit 0
fi

# Merge mode: runtime + services + optional override
compose_files=$(resolve_compose_files "$site_directory")

if [ -f "$site_directory/docker-compose.override.yml" ]; then
    compose_files="$compose_files:$site_directory/docker-compose.override.yml"
fi

# Compile merged config into a single file
compose_cmd=(docker compose --project-directory "$site_directory")
[ -f "$(pwd)/.env" ] && compose_cmd+=(--env-file "$(pwd)/.env")
IFS=':' read -ra files <<< "$compose_files"
for f in "${files[@]}"; do
    compose_cmd+=(-f "$f")
done

site_compose_file="$site_directory/docker-compose.yml"
"${compose_cmd[@]}" config > "$site_compose_file" || exit 1
echo "$site_compose_file"
