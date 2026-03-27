#!/bin/bash

# SimpleEpochConverter - Management Script
# Usage: ./manage.sh [command]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
APP_NAME="SimpleEpochConverter"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
EXECUTABLE="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
INFO_PLIST="$APP_BUNDLE/Contents/Info.plist"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  SimpleEpochConverter - Management${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Available commands:"
    echo ""
    echo -e "  ${GREEN}build${NC}      Build the application"
    echo -e "  ${GREEN}run${NC}        Run the application"
    echo -e "  ${GREEN}debug${NC}      Run with console output (for debugging)"
    echo -e "  ${GREEN}start${NC}      Build and run"
    echo -e "  ${GREEN}stop${NC}       Stop the application"
    echo -e "  ${GREEN}restart${NC}    Restart the application"
    echo -e "  ${GREEN}rebuild${NC}    Clean and rebuild"
    echo -e "  ${GREEN}verify${NC}     Verify build integrity"
    echo -e "  ${GREEN}clean${NC}      Remove build artifacts"
    echo -e "  ${GREEN}status${NC}     Check if app is running"
    echo -e "  ${GREEN}package${NC}    Create distributable .zip package"
    echo -e "  ${GREEN}help${NC}       Show this message"
    echo ""
}

cmd_build() {
    echo -e "${BLUE}🔨 Building SimpleEpochConverter...${NC}"
    
    if ! command -v swiftc &> /dev/null; then
        echo -e "${RED}❌ Swift not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Swift found${NC}"
    
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    # Copy icon if it exists
    if [ -f "$PROJECT_ROOT/Resources/AppIcon.icns" ]; then
        cp "$PROJECT_ROOT/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
        echo -e "${GREEN}✓ Icon copied${NC}"
    fi
    
    # Copy menu bar icon
    if [ -f "$PROJECT_ROOT/Resources/spiral.svg" ]; then
        cp "$PROJECT_ROOT/Resources/spiral.svg" "$APP_BUNDLE/Contents/Resources/"
        echo -e "${GREEN}✓ Menu bar icon copied${NC}"
    fi
    
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        TARGET="arm64-apple-macos13.0"
    else
        TARGET="x86_64-apple-macos13.0"
    fi
    
    echo -e "${BLUE}⚙️  Compiling...${NC}"
    swiftc \
        -o "$EXECUTABLE" \
        -framework Cocoa \
        -framework SwiftUI \
        -framework Carbon \
        -framework ServiceManagement \
        -target "$TARGET" \
        "$PROJECT_ROOT/Sources/SimpleEpochConverterApp.swift" \
        "$PROJECT_ROOT/Sources/ContentView.swift" \
        "$PROJECT_ROOT/Sources/HotKeyManager.swift" \
        "$PROJECT_ROOT/Sources/EpochConverter.swift" \
        "$PROJECT_ROOT/Sources/SettingsView.swift"
    
    cat > "$INFO_PLIST" << 'EOFPLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"\>
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SimpleEpochConverter</string>
    <key>CFBundleIdentifier</key>
    <string>com.alessandrobedini.SimpleEpochConverter</string>
    <key>CFBundleName</key>
    <string>SimpleEpochConverter</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app needs access to Apple Events to copy selected text.</string>
</dict>
</plist>
EOFPLIST
    
    echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"
    
    echo -e "${GREEN}✅ Build completed!${NC}"
}

cmd_run() {
    if [ ! -d "$APP_BUNDLE" ]; then
        echo -e "${RED}❌ App not built${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}🚀 Launching...${NC}"
    "$EXECUTABLE" > /dev/null 2>&1 &
}

cmd_run_debug() {
    if [ ! -d "$APP_BUNDLE" ]; then
        echo -e "${RED}❌ App not built${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🐛 Launching in debug mode (with console output)...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    "$EXECUTABLE"
}

cmd_start() {
    cmd_build
    cmd_run
}

cmd_stop() {
    killall "$APP_NAME" 2>/dev/null || echo -e "${BLUE}App not running${NC}"
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_run
}

cmd_rebuild() {
    cmd_clean
    cmd_build
}

cmd_verify() {
    echo -e "${BLUE}🔍 Verifying...${NC}"
    ERRORS=0
    
    [ -d "$APP_BUNDLE" ] && echo -e "${GREEN}✅${NC} Bundle OK" || { echo -e "${RED}❌${NC} No bundle"; ERRORS=$((ERRORS+1)); }
    [ -f "$EXECUTABLE" ] && echo -e "${GREEN}✅${NC} Executable OK" || { echo -e "${RED}❌${NC} No executable"; ERRORS=$((ERRORS+1)); }
    [ -f "$INFO_PLIST" ] && echo -e "${GREEN}✅${NC} Info.plist OK" || { echo -e "${RED}❌${NC} No Info.plist"; ERRORS=$((ERRORS+1)); }
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✅ All checks passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
        exit 1
    fi
}

cmd_clean() {
    rm -rf "$BUILD_DIR"
    echo -e "${GREEN}✅ Clean completed${NC}"
}

cmd_status() {
    echo -e "${BLUE}📊 Status${NC}"
    [ -d "$APP_BUNDLE" ] && echo -e "  Build: ${GREEN}OK${NC}" || echo -e "  Build: ${RED}Not built${NC}"
    pgrep -f "$APP_NAME" > /dev/null && echo -e "  Running: ${GREEN}Yes${NC}" || echo -e "  Running: ${YELLOW}No${NC}"
}

cmd_package() {
    echo -e "${BLUE}📦 Creating distributable package...${NC}"
    
    if [ ! -d "$APP_BUNDLE" ]; then
        echo -e "${RED}❌ App not built. Run './manage.sh build' first${NC}"
        exit 1
    fi
    
    VERSION=$(grep -A1 "CFBundleShortVersionString" "$INFO_PLIST" | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')
    PACKAGE_NAME="SimpleEpochConverter-${VERSION}.zip"
    PACKAGE_PATH="$BUILD_DIR/$PACKAGE_NAME"
    
    echo -e "${BLUE}Creating package: $PACKAGE_NAME${NC}"
    
    # Remove quarantine attributes
    xattr -cr "$APP_BUNDLE"
    
    # Create zip
    cd "$BUILD_DIR"
    zip -r -q "$PACKAGE_NAME" "$APP_NAME.app"
    cd "$SCRIPT_DIR"
    
    # Calculate SHA256
    SHA256=$(shasum -a 256 "$PACKAGE_PATH" | cut -d ' ' -f 1)
    
    echo -e "${GREEN}✅ Package created!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Location: ${GREEN}$PACKAGE_PATH${NC}"
    echo -e "  Size: $(du -h "$PACKAGE_PATH" | cut -f1)"
    echo -e "  SHA256: ${YELLOW}$SHA256${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Next steps for Homebrew:${NC}"
    echo -e "1. Create a GitHub release and upload this .zip"
    echo -e "2. Create a Homebrew formula using this SHA256"
    echo -e "3. Test with: brew install --build-from-source <formula>"
}

case "${1:-help}" in
    build) cmd_build ;;
    run) cmd_run ;;
    debug) cmd_run_debug ;;
    start) cmd_start ;;
    stop) cmd_stop ;;
    restart) cmd_restart ;;
    rebuild) cmd_rebuild ;;
    verify) cmd_verify ;;
    clean) cmd_clean ;;
    status) cmd_status ;;
    package) cmd_package ;;
    help|--help|-h) show_help ;;
    *) echo -e "${RED}Unknown command: $1${NC}"; show_help; exit 1 ;;
esac
