#!/usr/bin/env sh

hosts_file=/mnt/c/Windows/System32/drivers/etc/hosts
hosts_template_file=/mnt/c/Windows/System32/drivers/etc/hosts_template

if [ ! -f "$hosts_template_file" ]; then
  echo "Cannot update hosts file, since there is no template file ($hosts_template_file)"
  exit 1
fi

script_dir=$(dirname "$0")
updated_hosts="$(ls "$script_dir/sites" | sed "s/^/127.0.0.1 /" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
updated_hosts_mailpit="$(ls "$script_dir/sites" | sed "s/^/127.0.0.1 mail./" | sed "s/$/.local/" | tr '\n' '@' | sed 's/@/\\n/g')"
sed "
/# update-hosts-file start/,/# update-hosts-file end/{
  /# update-hosts-file start/!{
    /# update-hosts-file end/!d
  }
  /# update-hosts-file start/a\\
$updated_hosts$updated_hosts_mailpit
}" $hosts_template_file > $hosts_file
