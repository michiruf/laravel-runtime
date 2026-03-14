#!/usr/bin/env bash
# shellcheck disable=SC2155

# Resolve and compile the compose configuration for the current site.
# For sites with docker-compose.custom.yml: echoes that path (full replacement).
# For merge-based sites: compiles all compose files into docker-compose.yml.

site_directory=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-site-directory.sh" "$(pwd)")
if [ -z "$site_directory" ]; then
    exit 1
fi

# Full custom compose — use as-is
if [ -f "$site_directory/docker-compose.custom.yml" ]; then
    echo "$site_directory/docker-compose.custom.yml"
    exit 0
fi

# Temporary stub so docker compose resolves .env from the site directory
stub_file="$site_directory/docker-compose.stub.yml"
echo 'services: {}' > "$stub_file"

# Merge mode: runtime + services + optional override
service_compose_files=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-service-compose-files.sh" "$site_directory")
compose_files="${stub_file}:${service_compose_files}"

if [ -f "$site_directory/docker-compose.override.yml" ]; then
    compose_files="$compose_files:$site_directory/docker-compose.override.yml"
fi

# Compile merged config into a single file
config_file="$site_directory/docker-compose.yml"
compose_cmd=(docker compose --project-directory "$site_directory")
IFS=':' read -ra files <<< "$compose_files"
for f in "${files[@]}"; do
    compose_cmd+=(-f "$f")
done

"${compose_cmd[@]}" config > "$config_file"
rm -f "$stub_file"
echo "$config_file"
