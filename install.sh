#!/usr/bin/env sh

SCRIPT_DIRECTORY=$(dirname "$(realpath "$0")")

# Install Sail as a Composer dependency (no host PHP needed)
docker run --rm -v "$SCRIPT_DIRECTORY:/app" composer:latest composer install --no-dev --no-interaction --working-dir=/app
docker rmi composer:latest

if [ -n "${LARAVEL_RUNTIME_DIRECTORY+x}" ]; then
    echo 'LARAVEL_RUNTIME_DIRECTORY is already set, skipping .bashrc registration'
else
    # shellcheck disable=SC2129
    echo >> ~/.bashrc
    echo "# Laravel Runtime" >> ~/.bashrc
    echo "export LARAVEL_RUNTIME_DIRECTORY=$SCRIPT_DIRECTORY" >> ~/.bashrc
    cat >>~/.bashrc <<'EOF'
if [[ -d "$LARAVEL_RUNTIME_DIRECTORY" ]]; then
  source $LARAVEL_RUNTIME_DIRECTORY/.bashrc
else
  echo "Laravel runtime not found in '$LARAVEL_RUNTIME_DIRECTORY'" >&2
fi
EOF
    echo 'Validate your updated ~/.bashrc file, then source it'
fi
