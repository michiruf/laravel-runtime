#!/usr/bin/env sh

script_dir=$(dirname "$0")
updated_hosts="$(ls "$script_dir/sites" | sed "s/^/127.0.0.1 /" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
sed "
/# update-hosts-file start/,/# update-hosts-file end/{
  /# update-hosts-file start/!{
    /# update-hosts-file end/!d
  }
  /# update-hosts-file start/a\\
$updated_hosts
}" /mnt/c/Windows/System32/drivers/etc/hosts_template > /mnt/c/Windows/System32/drivers/etc/hosts
