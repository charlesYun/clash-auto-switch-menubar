#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_NAME="Clash Verge Auto Switch"
APP_DIR="$APP_PROJECT_DIR/build/${APP_NAME}.app"
RELEASE_DIR="$APP_PROJECT_DIR/build/release"
ZIP_PATH="$RELEASE_DIR/Clash-Verge-Auto-Switch-macOS-arm64.zip"

cd "$APP_PROJECT_DIR"

if [[ ! -d "$APP_DIR" ]]; then
  "$SCRIPT_DIR/build_app.sh"
fi

mkdir -p "$RELEASE_DIR"
rm -f "$ZIP_PATH"

/usr/bin/ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"

echo "Packaged: $ZIP_PATH"
