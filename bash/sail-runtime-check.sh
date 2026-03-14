# Avoid autocomplete for sail, since autocomplete calls the sail function
# Requires $LARAVEL_RUNTIME_DIRECTORY to be set
function sail-runtime-check {
    [[ -n "$COMP_LINE" ]] && return 1
    [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ] && { echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'; return 1; }

    # Check if runtime was installed
    if [ ! -f "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" ]; then
        echo "Sail is not installed. Run install.sh of the runtime first."
        return 1
    fi
}
