#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${PADEL_GODOT_BIN:-$project_root/../../work/tools/godot/Godot_v4.7.2-stable_linux.x86_64}"
if [[ ! -x "$godot_bin" ]]; then
  echo 'No se encontró Godot. Indicá su ejecutable en PADEL_GODOT_BIN.' >&2
  exit 1
fi
# Keep data/cache inside the project rather than writing outside this workspace.
export XDG_DATA_HOME="$project_root/.local/data"
export XDG_CONFIG_HOME="$project_root/.local/config"
export XDG_CACHE_HOME="$project_root/.local/cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
exec "$godot_bin" --path "$project_root/game" "$@"
