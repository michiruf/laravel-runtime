#!/usr/bin/env bash

# Discover available services by scanning runtime/*/docker-compose.yml
for service_compose in "$LARAVEL_RUNTIME_DIRECTORY"/runtime/*/docker-compose.yml; do
    [ -f "$service_compose" ] || continue
    dir_name=$(basename "$(dirname "$service_compose")")
    [ "$dir_name" != "sail" ] && echo "$dir_name"
done
