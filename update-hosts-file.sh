#!/usr/bin/env sh

### Variant using Docker
#updated_hosts=""
#running_containers=$(docker ps --format "{{.Names}}")
#for container_name in $running_containers; do
#  hostname=$(docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' $container_name | grep VIRTUAL_HOST | cut -d'=' -f2)
#  if [ -n "$hostname" ]; then
#    updated_hosts="${updated_hosts}\n127.0.0.1 $hostname"
#  fi
#done
#
#set -x
#sed "
#/# update-hosts-file start/,/# update-hosts-file end/{
#  /# update-hosts-file start/!{
#    /# update-hosts-file end/!d
#  }
#  /# update-hosts-file start/a\\
#$updated_hosts
#}" /mnt/c/Windows/System32/drivers/etc/hosts_template > /mnt/c/Windows/System32/drivers/etc/hosts
#set +x

### Variant using directories
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
