#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SOURCE_DIR}/common.sh"

# Clone the latest release of a GitHub repo into ${LOGOS_BASE}/{repo_name}.
gh_clone_latest() {
    local repo_slug="$1"
    local repo_name="${repo_slug##*/}"
    local api_url="https://api.github.com/repos/${repo_slug}"
    local dest="${LOGOS_BASE}/${repo_name}"

    local latest_release
    latest_release=$(curl -fsSL "${api_url}/releases/latest" | jq -r '.tag_name')

    if [[ -z "${latest_release}" || "${latest_release}" == "null" ]]; then
        echoerr "Error: could not determine latest release for ${repo_slug}" >&2
        return 1
    fi

    echoerr "Latest release of ${repo_slug}: ${latest_release}"

    if [[ -d "${dest}" ]]; then
        echoerr "Removing existing ${dest}"
        rm -rf "${dest}"
    fi

    mkdir -p "$(dirname "${dest}")"
    git clone --depth 1 --branch "${latest_release}" \
        "https://github.com/${repo_slug}.git" "${dest}"

    echoerr "Cloned ${repo_slug}@${latest_release} into ${dest}"
    echo "${latest_release}"
}
