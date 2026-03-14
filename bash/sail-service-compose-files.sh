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
    while IFS= read -r line; do services+=("$line"); done < <(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-service-discovery.sh")
fi

result="$LARAVEL_RUNTIME_DIRECTORY/runtime/sail/docker-compose.yml"
for service in "${services[@]}"; do
    compose_file="$LARAVEL_RUNTIME_DIRECTORY/runtime/$service/docker-compose.yml"
    [ -f "$compose_file" ] && result="$result:$compose_file"
done
echo "$result"
