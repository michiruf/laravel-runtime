#!/usr/bin/env bash

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
compose_files=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/site-compose-files.sh" "$site_directory")

if [ -f "$site_directory/docker-compose.override.yml" ]; then
    compose_files="$compose_files:$site_directory/docker-compose.override.yml"
fi

# Compile merged config into a single file
compose_cmd=(docker compose --project-directory "$site_directory" --env-file "$(pwd)/.env")
IFS=':' read -ra files <<< "$compose_files"
for f in "${files[@]}"; do
    compose_cmd+=(-f "$f")
done

site_compose_file="$site_directory/docker-compose.yml"
"${compose_cmd[@]}" config > "$site_compose_file"
echo "$site_compose_file"
