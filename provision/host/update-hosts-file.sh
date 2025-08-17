#!/usr/bin/env sh

# Requires $LARAVEL_RUNTIME_DIRECTORY to be set
if [ -z ${LARAVEL_RUNTIME_DIRECTORY+x} ]; then
    echo 'LARAVEL_RUNTIME_DIRECTORY environment variable must be set'
    return 1
fi

hosts_file=/mnt/c/Windows/System32/drivers/etc/hosts
hosts_template_file=/mnt/c/Windows/System32/drivers/etc/hosts_template

if [ ! -f "$hosts_template_file" ]; then
  echo "Cannot update hosts file, since there is no template file ($hosts_template_file)"
  exit 1
fi

updated_hosts="$(ls "$LARAVEL_RUNTIME_DIRECTORY/sites" | sed "s/^/127.0.0.1 /" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
updated_hosts_mailpit="$(ls "$LARAVEL_RUNTIME_DIRECTORY/sites" | sed "s/^/127.0.0.1 mail./" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
sed "
/# update-hosts-file start/,/# update-hosts-file end/{
  /# update-hosts-file start/!{
    /# update-hosts-file end/!d
  }
  /# update-hosts-file start/a\\
$updated_hosts$updated_hosts_mailpit
}" $hosts_template_file > $hosts_file
