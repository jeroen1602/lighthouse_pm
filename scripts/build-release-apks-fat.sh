#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR/../" || exit

flutter build apk --release --no-obfuscate \
  --flavor=defaultVersion \
  --dart-define=includeGooglePlayInAppPurchases=false \
  --dart-define=includeSupportButtons=true \
  --dart-define=includeSupportPage=true \
  --dart-define=includePaypal=true \
  --dart-define=includeGithubSponsor=true \
  --target-platform=android-arm,android-arm64,android-x64

EXIT_CODE=$?

if [ $EXIT_CODE != 0 ]; then
  echo 'Could not build'
  exit $EXIT_CODE
fi

set -e

mkdir -p "$SCRIPT_DIR/../output"

VERSION=$(grep -oP 'version: \K\d+\.\d+\.\d+(-.+)?\+\d+' "${SCRIPT_DIR}/../pubspec.yaml")

cp -vrf "${SCRIPT_DIR}/../build/app/outputs/flutter-apk/app-defaultversion-release.apk" "${SCRIPT_DIR}/../output/lighthouse_pm-${VERSION}.fat.apk"
