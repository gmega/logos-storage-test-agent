#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SOURCE_DIR}/common.sh"

mkdir -p "${LOGOS_BASE}"

_find_lgx() {
  local matches
  mapfile -t matches < <(find -L ./ -type f -name "*.lgx")
  if (( ${#matches[@]} != 1 )); then
    echoerr "Expected exactly 1 LGX file, found ${#matches[@]}"
    return 1
  fi
  realpath "${matches[0]}"
}

lg_build_local_basecamp() {
  cd "${LOGOS_BASE}/logos-basecamp" || return 1
  nix build '.#app' || return 1
  if [ -e ./result/bin/LogosBasecamp ]; then
    echo "./result/bin/LogosBasecamp"
  else
    echoerr "No output found"
    return 1
  fi
}

lg_build_local_lgx() {
  local lgx module

  module="$1"
  cd "${LOGOS_BASE}/${module}" || return 1
  nix bundle --bundler github:logos-co/nix-bundle-lgx ".#lib"
  lgx=$(_find_lgx)
  echoerr "LGX generated at ${lgx}"
  echo "${lgx}"
}

lg_build_storage_ui_lgx() {
  local lgx

  cd "${LOGOS_BASE}/logos-storage-ui" || return 1
  nix build '.#lgx' || return 1
  lgx=$(_find_lgx)
  echoerr "LGX generated at ${lgx}"
  echo "${lgx}"
}

lg_kill_basecamp() {
  pkill ".logos_host_qt-"
  pkill ".LogosBasecamp"
}

lg_start_basecamp() {
  lg_kill_basecamp
  "${LOGOS_BASE}/logos-basecamp/result/bin/LogosBasecamp" &
}

lg_install_module() {
  local lgx_path
  lgx_path="$1"
  python3 "${SOURCE_DIR}/logos-cli.py" install_module "$lgx_path"
}