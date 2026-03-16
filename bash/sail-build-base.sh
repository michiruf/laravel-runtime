#!/usr/bin/env bash

# Pre-build base sail image when building
if [[ "$1" == "build" || "$1" == "up" ]]; then
    php_version="${PHP_VERSION:-8.4}"
    sail_runtime="$LARAVEL_RUNTIME_DIRECTORY/vendor/laravel/sail/runtimes/$php_version"

    if [ ! -d "$sail_runtime" ]; then
        echo "Sail runtime for PHP $php_version not found at '$sail_runtime'." >&2
        echo "Run the install script first" >&2
        exit 1
    fi

    if [[ "$1" == "build" ]] || ! docker image inspect "sail-${php_version}/app" > /dev/null 2>&1; then
        echo "Building base sail image (PHP $php_version)..."
        docker build -t "sail-${php_version}/app" --build-arg WWWGROUP=1000 "$sail_runtime"
    fi
fi
