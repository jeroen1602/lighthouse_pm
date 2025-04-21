#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

"$SCRIPT_DIR"/build-release-apks-fat.sh
"$SCRIPT_DIR"/build-release-apks-github.sh
"$SCRIPT_DIR"/build-release-bundle-playstore.sh
"$SCRIPT_DIR"/build-release-github-pages.sh
