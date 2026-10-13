#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: install.sh [--force] [target-dir ...]" >&2
  echo "  default targets: ~/.claude/skills ~/.codex/skills" >&2
  echo "  --force  move an existing non-symlink skill aside (<name>.bak-<date>) and link ours" >&2
}

force=0
targets=()
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    -h|--help) usage; exit 0 ;;
    *) targets+=("$arg") ;;
  esac
done
[ "${#targets[@]}" -eq 0 ] && targets=("$HOME/.claude/skills" "$HOME/.codex/skills")

repo=$(cd "$(dirname "$0")" && pwd)
stamp=$(date +%Y%m%d%H%M%S)

link_skill() {
  local src=$1 dest_dir=$2 name dest
  name=$(basename "$src")
  dest="$dest_dir/$name"
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
    echo "  relinked  $name"
  elif [ -e "$dest" ]; then
    if [ "$force" -eq 1 ]; then
      mv "$dest" "$dest.bak-$stamp"
      ln -s "$src" "$dest"
      echo "  replaced  $name (old copy: $name.bak-$stamp)"
    else
      echo "  skipped   $name (a non-symlink copy exists; rerun with --force to replace it)"
    fi
  else
    ln -s "$src" "$dest"
    echo "  linked    $name"
  fi
}

for dest_dir in "${targets[@]}"; do
  mkdir -p "$dest_dir"
  echo "$dest_dir"
  for src in "$repo"/skills/*/; do
    link_skill "${src%/}" "$dest_dir"
  done
done
