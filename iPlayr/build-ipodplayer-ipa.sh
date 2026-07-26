#!/bin/bash
set -euo pipefail

# Builds an unsigned Release IPA of iPodPlayer for sideloading via SideStore/AltStore.
# Run this from inside the iPodPlayer/iPlayr directory (the one containing iPodPlayer.xcodeproj).
#
# Usage:
#   chmod +x build-ipodplayer-ipa.sh
#   ./build-ipodplayer-ipa.sh

# --- CHANGE THIS to a bundle ID you control -------------------------------
# This must match an App ID in your developer account that has MusicKit
# enabled under App Services, or the app will launch but every Apple Music
# request will fail at runtime.
BUNDLE_ID="com.yourname.ipodplayer"
# --------------------------------------------------------------------------

SCHEME="iPodPlayer"
PROJECT="iPodPlayer.xcodeproj"
OUT="$HOME/Desktop/iPodPlayer.ipa"

if [ ! -d "$PROJECT" ]; then
  echo "error: $PROJECT not found. cd into iPodPlayer/iPlayr first."
  exit 1
fi

echo "==> Building $SCHEME (Release, unsigned)"
rm -rf ./build
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ./build \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  DEVELOPMENT_TEAM="" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ENABLE_DEBUG_DYLIB=NO \
  clean build

APP="./build/Build/Products/Release-iphoneos/$SCHEME.app"
if [ ! -d "$APP" ]; then
  echo "error: build succeeded but $APP is missing."
  exit 1
fi

echo "==> Packaging IPA"
STAGE="$(mktemp -d)"
mkdir -p "$STAGE/Payload"
cp -R "$APP" "$STAGE/Payload/"

# Strip anything that trips up re-signing.
find "$STAGE" -name '.DS_Store' -delete
rm -rf "$STAGE/Payload/$SCHEME.app/_CodeSignature"
rm -f  "$STAGE/Payload/$SCHEME.app/embedded.mobileprovision"

rm -f "$OUT"
( cd "$STAGE" && zip -qry "$OUT" Payload )
rm -rf "$STAGE"

echo "==> Verifying"
if unzip -l "$OUT" | grep -q 'debug.dylib'; then
  echo "WARNING: debug dylib present — this is not a clean Release build."
fi
unzip -p "$OUT" "Payload/$SCHEME.app/Info.plist" \
  | plutil -extract CFBundleIdentifier raw - \
  | sed 's/^/    bundle id: /'
unzip -p "$OUT" "Payload/$SCHEME.app/Info.plist" \
  | plutil -extract MinimumOSVersion raw - \
  | sed 's/^/    min iOS:   /'

echo
echo "Done: $OUT ($(du -h "$OUT" | cut -f1))"
echo "AirDrop it to your iPhone, then open it in SideStore to sign and install."
