#!/usr/bin/env sh

SCRIPT_DIRECTORY=$(dirname "$(realpath "$0")")

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
echo 'Validate your uprated ~/.bashrc file, then source it'
