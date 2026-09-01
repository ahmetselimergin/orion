#!/bin/bash
set -e

echo "=== Orion macOS DMG Packager ==="

# 1. Ensure build exists
APP_PATH="build/macos/Build/Products/Release/orion.app"

if [ ! -d "$APP_PATH" ]; then
  echo "Error: Release build not found at $APP_PATH"
  echo "Running 'flutter build macos --release'..."
  flutter build macos --release
fi

# 2. Output folder setup
mkdir -p dist
DMG_PATH="dist/Orion-1.0.0.dmg"

# Remove existing dmg if any
rm -f "$DMG_PATH"

echo "Creating DMG installer at $DMG_PATH..."

# 3. Create DMG using create-dmg tool
ICON_PATH="$APP_PATH/Contents/Resources/AppIcon.icns"

if [ -f "$ICON_PATH" ]; then
  create-dmg \
    --volname "Orion" \
    --volicon "$ICON_PATH" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "orion.app" 175 120 \
    --hide-extension "orion.app" \
    --app-drop-link 425 120 \
    "$DMG_PATH" \
    "$APP_PATH"
else
  create-dmg \
    --volname "Orion" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "orion.app" 175 120 \
    --hide-extension "orion.app" \
    --app-drop-link 425 120 \
    "$DMG_PATH" \
    "$APP_PATH"
fi


echo "=== Success! DMG created at: $DMG_PATH ==="
