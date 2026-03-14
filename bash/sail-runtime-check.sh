# Avoid autocomplete for sail, since autocomplete calls the sail function
# Requires $LARAVEL_RUNTIME_DIRECTORY to be set
function sail-runtime-check {
    [[ -n "$COMP_LINE" ]] && return 1
    [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ] && { echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'; return 1; }
}
