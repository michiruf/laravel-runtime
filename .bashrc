for f in "$LARAVEL_RUNTIME_DIRECTORY"/bash/*.sh; do
    [ -f "$f" ] && source "$f"
done
