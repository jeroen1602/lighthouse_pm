#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR/../" || exit

flutter build appbundle --release --no-obfuscate \
  --dart-define=includeSupportButtons=false \
  --dart-define=includeSupportPage=false \
  --dart-define=includePaypal=false \
  --dart-define=includeGithubSponsor=false \
  --target-platform=android-arm,android-arm64,android-x64

EXIT_CODE=$?

if [ $EXIT_CODE != 0 ]; then
  echo 'Could not build'
  exit $EXIT_CODE
fi

set -e

mkdir -p "$SCRIPT_DIR/../output"

VERSION=$(grep -oP 'version: \K\d+\.\d+\.\d+(-.+)?\+\d+' "${SCRIPT_DIR}/../pubspec.yaml")

cp -vrf "${SCRIPT_DIR}/../build/app/outputs/bundle/googlePlayRelease/app-googlePlay-release.aab" "$SCRIPT_DIR/../output/googlePlay-${VERSION}.aab"
