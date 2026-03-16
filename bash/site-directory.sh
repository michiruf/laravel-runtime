#!/usr/bin/env bash

# Resolve the site directory for the current project by walking upward from
# the given path, building progressively longer relative paths and checking
# for a match under $LARAVEL_RUNTIME_DIRECTORY/sites/.
# e.g. for /home/app/my/sub/project, checks:
#   sites/project -> sites/sub/project -> sites/my/sub/project

search_path="$PROJECT_PATH"
relative_path=""

while [ "$search_path" != "/" ]; do
    segment=$(basename "$search_path")
    relative_path="$segment${relative_path:+/$relative_path}"

    candidate="$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path"
    [ -d "$candidate" ] && { echo "$candidate"; exit 0; }

    search_path=$(dirname "$search_path")
done

echo "No site directory found for '$(basename "${1:-$(pwd)}")'." >&2
echo "Run 'sail-setup' from your project directory first." >&2
exit 1
