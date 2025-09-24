#!/bin/bash

SCRIPT_DIR="${1:-/etc/sail-init}"

if [ -d "$SCRIPT_DIR" ]; then
    echo "Running initialization scripts from $SCRIPT_DIR"

    # Sort scripts to ensure predictable execution order
    for script in $(find "$SCRIPT_DIR" -type f -executable | sort); do
        echo "Executing: $script"
        if [ -x "$script" ]; then
            "$script"
            exit_code=$?
            if [ $exit_code -ne 0 ]; then
                echo "Script $script failed with exit code $exit_code"
                exit $exit_code
            fi
        fi
    done

    echo "All initialization scripts completed"
else
    echo "Directory $SCRIPT_DIR does not exist, skipping initialization scripts"
fi

start-container
