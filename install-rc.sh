#!/usr/bin/env sh

SCRIPT_DIRECTORY=$(dirname "$(realpath "$0")")

echo '' >> ~/.bashrc
echo '' >> ~/.bashrc
echo '# Laravel Runtime' >> ~/.bashrc
echo "export LARAVEL_RUNTIME_DIRECTORY=$SCRIPT_DIRECTORY" >> ~/.bashrc
echo "source $SCRIPT_DIRECTORY/.bashrc" >> ~/.bashrc
echo 'Validate your uprated ~/.bashrc file, then source it'
