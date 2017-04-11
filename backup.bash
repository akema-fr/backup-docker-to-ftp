#!/usr/bin/env bash

help() {
  echo "Usage: backup.bash [--create|--get-volumes|--help] container_id" >&2
  echo "Usage: backup.bash --send archive.tar.gz ftp_host" >&2
  exit 2
}

get_volumes() {
  local container_name="$1"
  docker inspect "$container_name" --format "{{ range .Mounts }}{{ .Source }} {{ end }}"
}

create_archive() {
  local container_name="$1"
  local date
  files="$(get_volumes "$container_name")"
  filepath="/tmp/$container_name.data-$(date '+%Y-%m-%d').tar.gz"

  tar --create --gzip --file "$filepath" $files
  chown "$USER":"$USER" "$filepath"

  echo "$filepath"
}

send_archive() {
  local archive_filepath="$1"
  local ftp_host="$2"
  curl \
    --upload-file "$archive_filepath" "ftp://$ftp_host" \
    --user "$FTP_USER":"$FTP_PASSWORD"
}


optspec=":hv-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
          case "${OPTARG}" in
            create)
              create_archive "${!#}";;
            send)
              send_archive "${@:(-2)}";;
            get-volumes)
              get_volumes "${!#}";;
            help)
              help;;
            *)
              echo "Error unknown argument.";;
          esac;;
        h)
            help;;
        v)
            echo "Parsing option: '-${optchar}'" >&2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done
