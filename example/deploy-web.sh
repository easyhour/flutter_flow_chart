#!/bin/bash

set -e
set -x

SERVER="root@dev.easyhour.app"
WEBAPP_PATH="/var/www/dev.easyhour.app/test-editor/"

flutter clean
flutter pub get
flutter build web --release --base-href "/test-editor/"
ssh "$SERVER" mkdir -p "$WEBAPP_PATH"
rsync -avz "build/web/" "$SERVER:$WEBAPP_PATH"
