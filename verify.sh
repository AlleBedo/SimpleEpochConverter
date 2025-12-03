#!/bin/bash

# Script di verifica per SimpleEpochConverter
# Controlla che l'app sia compilata correttamente

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BUNDLE="$SCRIPT_DIR/build/SimpleEpochConverter.app"
EXECUTABLE="$APP_BUNDLE/Contents/MacOS/SimpleEpochConverter"
INFO_PLIST="$APP_BUNDLE/Contents/Info.plist"

# Colori
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Verifica SimpleEpochConverter"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0

# 1. Verifica bundle
if [ -d "$APP_BUNDLE" ]; then
    echo -e "${GREEN}✅${NC} App bundle esiste"
else
    echo -e "${RED}❌${NC} App bundle non trovato"
    ERRORS=$((ERRORS + 1))
fi

# 2. Verifica eseguibile
if [ -f "$EXECUTABLE" ]; then
    echo -e "${GREEN}✅${NC} Eseguibile esiste"
    
    # Verifica permessi di esecuzione
    if [ -x "$EXECUTABLE" ]; then
        echo -e "${GREEN}✅${NC} Eseguibile ha permessi corretti"
    else
        echo -e "${RED}❌${NC} Eseguibile non è eseguibile"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Verifica architettura
    ARCH=$(file "$EXECUTABLE" | grep -o 'x86_64\|arm64')
    if [ -n "$ARCH" ]; then
        echo -e "${GREEN}✅${NC} Architettura: $ARCH"
    else
        echo -e "${RED}❌${NC} Architettura non riconosciuta"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${RED}❌${NC} Eseguibile non trovato"
    ERRORS=$((ERRORS + 1))
fi

# 3. Verifica Info.plist
if [ -f "$INFO_PLIST" ]; then
    echo -e "${GREEN}✅${NC} Info.plist esiste"
    
    # Verifica CFBundleExecutable
    BUNDLE_EXEC=$(defaults read "$APP_BUNDLE/Contents/Info" CFBundleExecutable 2>/dev/null)
    if [ "$BUNDLE_EXEC" = "SimpleEpochConverter" ]; then
        echo -e "${GREEN}✅${NC} CFBundleExecutable corretto: $BUNDLE_EXEC"
    else
        echo -e "${RED}❌${NC} CFBundleExecutable errato: '$BUNDLE_EXEC' (dovrebbe essere 'SimpleEpochConverter')"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Verifica che non ci siano variabili Xcode non sostituite
    if grep -q '\$(' "$INFO_PLIST"; then
        echo -e "${YELLOW}⚠️${NC}  Info.plist contiene variabili non sostituite:"
        grep '\$(' "$INFO_PLIST"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✅${NC} Nessuna variabile Xcode non sostituita"
    fi
else
    echo -e "${RED}❌${NC} Info.plist non trovato"
    ERRORS=$((ERRORS + 1))
fi

# 4. Verifica struttura
echo ""
echo "📁 Struttura app bundle:"
if [ -d "$APP_BUNDLE/Contents/MacOS" ]; then
    echo -e "${GREEN}✅${NC} Contents/MacOS/"
fi
if [ -d "$APP_BUNDLE/Contents/Resources" ]; then
    echo -e "${GREEN}✅${NC} Contents/Resources/"
fi
if [ -f "$APP_BUNDLE/Contents/PkgInfo" ]; then
    echo -e "${GREEN}✅${NC} Contents/PkgInfo"
fi

# 5. Test apertura (opzionale)
echo ""
echo "🧪 Test apertura app bundle:"
if open -Ra "$APP_BUNDLE" 2>/dev/null; then
    echo -e "${GREEN}✅${NC} App bundle può essere aperto da macOS"
else
    echo -e "${RED}❌${NC} Errore nell'apertura dell'app bundle"
    ERRORS=$((ERRORS + 1))
fi

# Risultato finale
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Tutti i controlli superati!${NC}"
    echo ""
    echo "L'app è pronta per essere eseguita:"
    echo "  ./run.sh"
    exit 0
else
    echo -e "${RED}❌ Trovati $ERRORS errori${NC}"
    echo ""
    echo "Prova a ricompilare:"
    echo "  ./build.sh"
    exit 1
fi
