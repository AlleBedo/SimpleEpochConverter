#!/bin/bash

# Create icon from icon.png
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ICON_SOURCE="$PROJECT_ROOT/Resources/icon.png"
ICONSET_DIR="$PROJECT_ROOT/build/AppIcon.iconset"
ICON_OUTPUT="$PROJECT_ROOT/Resources/AppIcon.icns"

# Check if source icon exists
if [ ! -f "$ICON_SOURCE" ]; then
    echo "❌ Error: $ICON_SOURCE not found!"
    exit 1
fi

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

echo "🎨 Generating icon sizes..."

# Generate all required sizes
sips -z 16 16     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null 2>&1
sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null 2>&1
sips -z 32 32     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null 2>&1
sips -z 64 64     "$ICON_SOURCE" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null 2>&1
sips -z 128 128   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null 2>&1
sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null 2>&1
sips -z 256 256   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null 2>&1
sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null 2>&1
sips -z 512 512   "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null 2>&1
sips -z 1024 1024 "$ICON_SOURCE" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null 2>&1

echo "📦 Converting to .icns format..."

# Convert to icns
iconutil -c icns "$ICONSET_DIR" -o "$ICON_OUTPUT"

# Cleanup
rm -rf "$ICONSET_DIR"

if [ -f "$ICON_OUTPUT" ]; then
    echo "✅ AppIcon.icns created successfully!"
    ls -lh "$ICON_OUTPUT"
else
    echo "❌ Failed to create AppIcon.icns"
    exit 1
fi
