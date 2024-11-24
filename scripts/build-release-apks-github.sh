#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR/../" || exit

patch -p1 -d "${SCRIPT_DIR}/../" <"${SCRIPT_DIR}/split-per-abi-build.gradle.patch"

BUILD_FLAVOR="release"

flutter build apk --"$BUILD_FLAVOR" --no-obfuscate \
  --dart-define=includeSupportButtons=true \
  --dart-define=includeSupportPage=true \
  --dart-define=includePaypal=true \
  --dart-define=includeGithubSponsor=true \
  --split-per-abi \
  --target-platform=android-arm,android-arm64,android-x64

EXIT_CODE=$?

patch -p1 -R -d "${SCRIPT_DIR}/../" <"${SCRIPT_DIR}/split-per-abi-build.gradle.patch"

if [ $EXIT_CODE != 0 ]; then
  echo 'Could not build'
  exit $EXIT_CODE
fi

set -e

mkdir -p "$SCRIPT_DIR/../output"

VERSION=$(grep -oP 'version: \K\d+\.\d+\.\d+(-.+)?\+\d+' "${SCRIPT_DIR}/../pubspec.yaml")

function copy_result() {
  VERSION=$1
  ABI=$2
  NEW_ABI=$3
  ORIGINAL_PATH="${SCRIPT_DIR}/../build/app/outputs/flutter-apk/app-${ABI}-defaultversion-$BUILD_FLAVOR.apk"
  NEW_PATH="${SCRIPT_DIR}/../output/lighthouse_pm-${VERSION}.${NEW_ABI}.apk"
  cp -vrf "$ORIGINAL_PATH" "$NEW_PATH"
}

copy_result "$VERSION" "armeabi-v7a" "arm"
copy_result "$VERSION" "arm64-v8a" "arm64"
copy_result "$VERSION" "x86_64" "X64"
