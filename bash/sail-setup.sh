#!/usr/bin/env bash

local_project_path="$(pwd)"
site_directory=$(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-site-directory.sh" "$local_project_path")

if [ -n "$site_directory" ]; then
    echo "Using existing site: ${site_directory#$LARAVEL_RUNTIME_DIRECTORY/}"
else
    options=()
    search_path="$local_project_path"
    relative_path=""

    while [ "$search_path" != "/" ]; do
        segment=$(basename "$search_path")
        relative_path="$segment${relative_path:+/$relative_path}"
        [ ! -d "$LARAVEL_RUNTIME_DIRECTORY/sites/$relative_path" ] && options+=("$relative_path")
        search_path=$(dirname "$search_path")
    done

    if [ ${#options[@]} -eq 0 ]; then
        echo "No available site paths (all conflict with existing sites)."
        exit 1
    fi

    echo "Select site path:"
    for i in "${!options[@]}"; do
        echo "  $((i + 1))) ${options[$i]}"
    done

    choice=""
    read -rp "Choice [1]: " choice
    choice="${choice:-1}"

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#options[@]}" ]; then
        echo "Invalid choice."
        exit 1
    fi

    site_directory="$LARAVEL_RUNTIME_DIRECTORY/sites/${options[$((choice - 1))]}"
fi

mkdir -p "$site_directory"

# Discover available services
available_services=()
while IFS= read -r svc; do available_services+=("$svc"); done < <(bash "$LARAVEL_RUNTIME_DIRECTORY/bash/sail-service-discovery.sh")

# Load existing selection as defaults, or default to all
current_services=()
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
default_indices=()
echo ""
echo "Select services (comma-separated, 0 for none, or Enter for defaults):"
echo "  0) none"
for i in "${!available_services[@]}"; do
    svc="${available_services[$i]}"
    marker=""
    if [[ -n "${current_set[$svc]+x}" ]]; then
        default_indices+=("$((i + 1))")
        marker=" (default)"
    fi
    echo "  $((i + 1))) ${svc}${marker}"
done
default_choice=$(IFS=,; echo "${default_indices[*]}")

service_choice=""
read -rp "Choice [$default_choice]: " service_choice
service_choice="${service_choice:-$default_choice}"

# Parse selection and write .sail-services
# Selecting 0 leaves the file empty, meaning no additional services (sail only)
: > "$site_directory/.sail-services"
if [ "$service_choice" != "0" ]; then
    IFS=',' read -ra selected_indices <<< "$service_choice"
    for idx in "${selected_indices[@]}"; do
        idx="${idx// /}"
        if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#available_services[@]}" ]; then
            echo "${available_services[$((idx - 1))]}" >> "$site_directory/.sail-services"
        fi
    done
fi

echo ""
echo "Created ${site_directory#"$LARAVEL_RUNTIME_DIRECTORY"/}/"
echo "Services: $(tr '\n' ' ' < "$site_directory/.sail-services")"
