function sail-setup {
    sail-runtime-check

    local project_path="$(pwd)"

    # Check if a site directory already exists for this project
    local site_directory
    site_directory=$(sail-site-directory "$project_path")

    if [ -n "$site_directory" ]; then
        local relative="${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}"
        echo "Using existing site: $relative"
    else
        # Build path options by walking up from current directory
        local options=()
        local search_path="$project_path"
        local relative_path=""

        while [ "$search_path" != "/" ]; do
            local segment=$(basename "$search_path")

            if [ -z "$relative_path" ]; then
                relative_path="$segment"
            else
                relative_path="$segment/$relative_path"
            fi

            # Skip paths that conflict with an existing site directory
            local candidate="$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path"
            if [ ! -d "$candidate" ]; then
                options+=("$relative_path")
            fi

            search_path=$(dirname "$search_path")
        done

        if [ ${#options[@]} -eq 0 ]; then
            echo "No available site paths (all conflict with existing sites)."
            return 1
        fi

        # Present options to user
        echo "Select site path:"
        for i in "${!options[@]}"; do
            echo "  $((i + 1))) ${options[$i]}"
        done

        local choice
        read -rp "Choice [1]: " choice
        choice="${choice:-1}"

        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#options[@]}" ]; then
            echo "Invalid choice."
            return 1
        fi

        site_directory="$LARAVEL_RUNTIME_DIRECTORY/sites/${options[$((choice - 1))]}"
    fi

    mkdir -p "$site_directory"

    # Write minimal docker-compose.yml for .env resolution
    cat > "$site_directory/docker-compose.yml" <<'COMPOSE'
services: {}
COMPOSE

    # Discover available services
    local available_services=()
    while IFS= read -r svc; do
        available_services+=("$svc")
    done < <(sail-service-discovery)

    # Read existing selection as defaults (or default to all)
    local current_services=()
    if [ -f "$site_directory/.sail-services" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [ -n "$line" ] && current_services+=("$line")
        done < "$site_directory/.sail-services"
    else
        current_services=("${available_services[@]}")
    fi

    # Build default indices
    local default_indices=()
    for i in "${!available_services[@]}"; do
        for current in "${current_services[@]}"; do
            if [ "${available_services[$i]}" = "$current" ]; then
                default_indices+=("$((i + 1))")
                break
            fi
        done
    done
    local default_choice
    default_choice=$(IFS=,; echo "${default_indices[*]}")

    # Present service selection
    echo ""
    echo "Select services (comma-separated, or Enter for defaults):"
    for i in "${!available_services[@]}"; do
        local marker=""
        for current in "${current_services[@]}"; do
            if [ "${available_services[$i]}" = "$current" ]; then
                marker=" (default)"
                break
            fi
        done
        echo "  $((i + 1))) ${available_services[$i]}${marker}"
    done

    local service_choice
    read -rp "Choice [$default_choice]: " service_choice
    service_choice="${service_choice:-$default_choice}"

    # Parse selection and write .sail-services
    > "$site_directory/.sail-services"
    IFS=',' read -ra selected_indices <<< "$service_choice"
    for idx in "${selected_indices[@]}"; do
        idx=$(echo "$idx" | tr -d ' ')
        if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#available_services[@]}" ]; then
            echo "${available_services[$((idx - 1))]}" >> "$site_directory/.sail-services"
        fi
    done

    # Symlink project .env into site directory
    rm -f "$site_directory/.env"
    if [ -f "$project_path/.env" ]; then
        ln -s "$project_path/.env" "$site_directory/.env"
    fi

    local relative="${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}"
    echo ""
    echo "Created $relative/"
    echo "Services: $(cat "$site_directory/.sail-services" | tr '\n' ' ')"
}
