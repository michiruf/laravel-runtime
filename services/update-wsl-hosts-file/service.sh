#!/usr/bin/env sh
[ "$SERVICE_UPDATE_WSL_HOSTS_FILE" != "true" ] && exit 0

# Requires $LARAVEL_RUNTIME_DIRECTORY to be set
if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
    echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
    exit 1
fi

hosts_file=/mnt/c/Windows/System32/drivers/etc/hosts

if [ -z "${WSL_HOSTS_TEMPLATE}" ]; then
    echo "WSL_HOSTS_TEMPLATE must be set in .env"
    exit 1
fi

sites="$(find "$LARAVEL_RUNTIME_DIRECTORY/sites" \( -name docker-compose.yml -o -name docker-compose.custom.yml \) -printf '%h\n' | sort -u | xargs -I{} basename {})"
updated_hosts="$(echo "$sites" | sed "s/^/127.0.0.1 /" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
updated_hosts_mailpit="$(echo "$sites" | sed "s/^/127.0.0.1 mail./" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
echo "$WSL_HOSTS_TEMPLATE" | sed "
/# update-hosts-file start/,/# update-hosts-file end/{
  /# update-hosts-file start/!{
    /# update-hosts-file end/!d
  }
  /# update-hosts-file start/a\\
$updated_hosts$updated_hosts_mailpit
}" > $hosts_file
