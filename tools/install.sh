#!/usr/bin/env bash
# Builds and installs the storage module and UI against basecamp. Used
# by the agent (together with instructions) to understand how this is done.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SOURCE_DIR}/logos.sh"
source "${SOURCE_DIR}/github.sh"

CORE_MODULE_VERSION=$(gh_clone_latest "logos-co/logos-storage-module")
UI_MODULE_VERSION=$(gh_clone_latest "logos-co/logos-storage-ui")
BASECAMP_VERSION=$(gh_clone_latest "logos-co/logos-basecamp")

echo "Test ${CORE_MODULE_VERSION} (core) and ${UI_MODULE_VERSION}" \
  "(UI) against basecamp ${BASECAMP_VERSION}."

BASECAMP_BIN=$(lg_build_local_basecamp)
CORE_LGX_PATH=$(lg_build_local_lgx "logos-storage-module")

# The UI module uses a non-standard build.
UI_LGX_PATH=$(lg_build_storage_ui_lgx)

lg_start_basecamp "$BASECAMP_BIN"
lg_install_module "$CORE_LGX_PATH"
lg_install_module "$UI_LGX_PATH"

