#!/usr/bin/env bash

# Return colon-separated compose file paths for the given site directory's services.
# Reads from .sail-services if present, otherwise falls back to all discovered services.

site_directory="$1"
services=()

if [ -n "$site_directory" ] && [ -f "$site_directory/.sail-services" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [ -n "$line" ] && services+=("$line")
    done < "$site_directory/.sail-services"
else
    while IFS= read -r line; do services+=("$line"); done < <(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/runtime-discovery.sh")
fi

result="$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml"

# Auto-discover feature compose files in any runtime subdirectory
# Convention: runtime/{service}/{feature}/docker-compose.yml
# Included when env var {SERVICE}_{FEATURE}=true (dashes become underscores, uppercased)
# Example: runtime/sail/install-claude-code/docker-compose.yml → SAIL_INSTALL_CLAUDE_CODE
# Example: runtime/mysql/create-test-database/docker-compose.yml → MYSQL_CREATE_TEST_DATABASE
for feature_compose in "$LARAVEL_RUNTIME_DIRECTORY"/runtime/*/*/docker-compose.yml; do
    [ -f "$feature_compose" ] || continue
    feature=$(basename "$(dirname "$feature_compose")")
    dir_name=$(basename "$(dirname "$(dirname "$feature_compose")")")
    env_var="$(echo "${dir_name}_${feature}" | tr '[:lower:]-' '[:upper:]_')"
    [ "${!env_var}" = "true" ] && result="$result:$feature_compose"
done

for service in "${services[@]}"; do
    compose_file="$LARAVEL_RUNTIME_DIRECTORY/runtime/$service/docker-compose.yml"
    [ -f "$compose_file" ] && result="$result:$compose_file"
done
echo "$result"
