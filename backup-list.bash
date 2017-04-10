#!/usr/bin/env bash
# USAGE
#   PATH=$PATH:./ backup-to-online.net.bash

scriptDir=$(dirname "$(readlink -f "$0")")
# shellcheck source=./credentials.conf
source ${1:-$scriptDir/credentials.conf}

while IFS='' read -r container_id || [[ -n "$container_id" ]]; do
  archive_filepath=$($scriptDir/backup.bash --create $container_id)
  $scriptDir/backup.bash --send "$archive_filepath" $FTP_HOST
done < $scriptDir/dockers-to-backup.txt
