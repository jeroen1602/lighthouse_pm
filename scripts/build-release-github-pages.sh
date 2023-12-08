#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cd "$SCRIPT_DIR/../" || exit

flutter build web --release \
  --dart-define=includeGooglePlayInAppPurchases=false \
  --dart-define=includeSupportButtons=true \
  --dart-define=includeSupportPage=true \
  --dart-define=includePaypal=true \
  --dart-define=includeGithubSponsor=true \
  --base-href="/lighthouse_pm/" \
  --pwa-strategy=offline-first

EXIT_CODE=$?

if [ $EXIT_CODE != 0 ]; then
  echo 'Could not build'
  exit $EXIT_CODE
fi

set -e

cp -vrf "${SCRIPT_DIR}/../build/web/" "${SCRIPT_DIR}/../output/web/"

perl -pi -e 's/"\/":/"\/lighthouse_pm\/":/' "${SCRIPT_DIR}/../output/web/flutter_service_worker.js"
