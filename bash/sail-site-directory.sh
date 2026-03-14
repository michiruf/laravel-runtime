#!/usr/bin/env bash
# shellcheck disable=SC2155

# Resolve the site directory for the current project by walking upward from
# the given path, building progressively longer relative paths and checking
# for a match under $LARAVEL_RUNTIME_DIRECTORY/sites/.
# e.g. for /home/app/my/sub/project, checks:
#   sites/project -> sites/sub/project -> sites/my/sub/project

search_path="${1:-$(pwd)}"
relative_path=""

while [ "$search_path" != "/" ]; do
    segment=$(basename "$search_path")
    relative_path="$segment${relative_path:+/$relative_path}"

    candidate="$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path"
    [ -d "$candidate" ] && { echo "$candidate"; exit 0; }

    search_path=$(dirname "$search_path")
done
exit 1
