sail-check() {
    [[ -n "$COMP_LINE" ]] && return 1
    [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ] && { echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'; return 1; }
    if [ ! -f "$LARAVEL_RUNTIME_DIRECTORY/vendor/bin/sail" ]; then
        echo "Sail is not installed. Run install.sh of the runtime first."
        return 1
    fi
}

sail() {
    sail-check || return 1
    bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail.sh" "$@"
}

sail-setup() {
    sail-check || return 1
    bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-setup.sh" "$@"
}
