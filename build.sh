#!/bin/bash

# Script per compilare SimpleEpochConverter senza Xcode
# Uso: ./build.sh

set -e

echo "🔨 Compilazione di SimpleEpochConverter..."

# Colori per output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica che Swift sia installato
if ! command -v swiftc &> /dev/null; then
    echo -e "${RED}❌ Swift non trovato. Installa Xcode Command Line Tools:${NC}"
    echo "xcode-select --install"
    exit 1
fi

echo -e "${BLUE}✓ Swift trovato: $(swift --version | head -n 1)${NC}"

# Directory di lavoro
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
APP_NAME="SimpleEpochConverter"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

# Pulizia build precedente
echo -e "${BLUE}🧹 Pulizia build precedente...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Crea la struttura dell'app bundle
echo -e "${BLUE}📦 Creazione struttura app bundle...${NC}"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Rileva l'architettura del sistema
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TARGET="arm64-apple-macos13.0"
    echo -e "${BLUE}🔧 Architettura rilevata: Apple Silicon (arm64)${NC}"
else
    TARGET="x86_64-apple-macos13.0"
    echo -e "${BLUE}🔧 Architettura rilevata: Intel (x86_64)${NC}"
fi

# Compila i file Swift
echo -e "${BLUE}⚙️  Compilazione file Swift...${NC}"
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework Carbon \
    -target "$TARGET" \
    "$SCRIPT_DIR/SimpleEpochConverterApp.swift" \
    "$SCRIPT_DIR/ContentView.swift" \
    "$SCRIPT_DIR/HotKeyManager.swift" \
    "$SCRIPT_DIR/EpochConverter.swift" \
    "$SCRIPT_DIR/ResultWindow.swift"

# Crea Info.plist con valori corretti (sostituendo le variabili Xcode)
echo -e "${BLUE}📄 Creazione Info.plist...${NC}"
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$APP_NAME</string>
	<key>CFBundleIdentifier</key>
	<string>com.alessandrobedini.SimpleEpochConverter</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$APP_NAME</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2025. All rights reserved.</string>
	<key>NSAppleEventsUsageDescription</key>
	<string>Questa app ha bisogno dell'accesso agli eventi Apple per copiare il testo selezionato.</string>
	<key>NSAppleScriptEnabled</key>
	<true/>
</dict>
</plist>
EOF

# Copia entitlements (per riferimento, non viene applicato senza code signing)
cp "$SCRIPT_DIR/SimpleEpochConverter.entitlements" "$APP_BUNDLE/Contents/Resources/"

# Crea PkgInfo
echo "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo -e "${GREEN}✅ Compilazione completata!${NC}"
echo ""
echo -e "${GREEN}🚀 Per eseguire l'app:${NC}"
echo -e "   ${BLUE}open $APP_BUNDLE${NC}"
echo ""
echo -e "${GREEN}📍 L'app si trova in:${NC}"
echo -e "   ${BLUE}$APP_BUNDLE${NC}"
echo ""
echo -e "⚠️  ${RED}NOTA:${NC} Senza code signing, dovrai autorizzare l'app in:"
echo -e "   Preferenze di Sistema → Privacy e Sicurezza"
echo ""
