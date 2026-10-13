#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 6 ]; then
  echo "usage: log.sh <logfile> <phase> <decision> <why> <evidence> <result>" >&2
  exit 2
fi

logfile=$1
shift

sanitize() {
  printf '%s' "$1" | tr '\t\n\r' '   ' | sed "s/^[=+@-]/'&/"
}

mkdir -p "$(dirname "$logfile")"
if [ ! -s "$logfile" ]; then
  printf 'ts\tphase\tdecision\twhy\tevidence\tresult\n' > "$logfile"
fi

row=$(date -u +%Y-%m-%dT%H:%M:%SZ)
for cell in "$@"; do
  row="$row$(printf '\t')$(sanitize "$cell")"
done
printf '%s\n' "$row" >> "$logfile"
