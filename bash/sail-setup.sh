# shellcheck disable=SC2155

function sail-setup {
    sail-runtime-check

    local project_path="$(pwd)"
    local site_directory=$(sail-site-directory "$project_path")

    if [ -n "$site_directory" ]; then
        echo "Using existing site: ${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}"
    else
        local options=()
        local search_path="$project_path"
        local relative_path=""

        while [ "$search_path" != "/" ]; do
            local segment=$(basename "$search_path")
            relative_path="$segment${relative_path:+/$relative_path}"
            [ ! -d "$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path" ] && options+=("$relative_path")
            search_path=$(dirname "$search_path")
        done

        if [ ${#options[@]} -eq 0 ]; then
            echo "No available site paths (all conflict with existing sites)."
            return 1
        fi

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

    # Discover available services
    local available_services=()
    while IFS= read -r svc; do available_services+=("$svc"); done < <(sail-service-discovery)

    # Load existing selection as defaults, or default to all
    local current_services=()
    if [ -f "$site_directory/.sail-services" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            [ -n "$line" ] && current_services+=("$line")
        done < "$site_directory/.sail-services"
    else
        current_services=("${available_services[@]}")
    fi

    # Build lookup set for current services
    declare -A current_set=()
    for svc in "${current_services[@]}"; do current_set["$svc"]=1; done

    # Present service selection
    local default_indices=()
    echo ""
    echo "Select services (comma-separated, or Enter for defaults):"
    for i in "${!available_services[@]}"; do
        local svc="${available_services[$i]}"
        local marker=""
        if [[ -n "${current_set[$svc]+x}" ]]; then
            default_indices+=("$((i + 1))")
            marker=" (default)"
        fi
        echo "  $((i + 1))) ${svc}${marker}"
    done
    local default_choice=$(IFS=,; echo "${default_indices[*]}")

    local service_choice
    read -rp "Choice [$default_choice]: " service_choice
    service_choice="${service_choice:-$default_choice}"

    # Parse selection and write .sail-services
    : > "$site_directory/.sail-services"
    IFS=',' read -ra selected_indices <<< "$service_choice"
    for idx in "${selected_indices[@]}"; do
        idx="${idx// /}"
        if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#available_services[@]}" ]; then
            echo "${available_services[$((idx - 1))]}" >> "$site_directory/.sail-services"
        fi
    done

    rm -f "$site_directory/.env"
    [ -f "$project_path/.env" ] && ln -s "$project_path/.env" "$site_directory/.env"

    echo ""
    echo "Created ${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}/"
    echo "Services: $(tr '\n' ' ' < "$site_directory/.sail-services")"
}
