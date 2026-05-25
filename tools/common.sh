#!/usr/bin/env bash

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGOS_BASE="$(cd "${SOURCE_DIR}/.." && pwd)/logos"

echoerr() { echo "$@" >&2; }
