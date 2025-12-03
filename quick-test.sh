#!/bin/bash

# Script tutto-in-uno per compilare ed eseguire
# Uso: ./quick-test.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 Quick Test - SimpleEpochConverter"
echo ""

# Compila
echo "1️⃣ Compilazione..."
"$SCRIPT_DIR/build.sh"

echo ""
echo "2️⃣1 Avvio app..."
sleep 1

# Esegui
open "$SCRIPT_DIR/build/SimpleEpochConverter.app"

echo ""
echo "✅ App avviata!"
echo ""
echo "📝 COME TESTARE:"
echo "   1. Vedrai un'icona di orologio nella menu bar"
echo "   2. Apri un editor di testo (TextEdit, Notes, ecc.)"
echo "   3. Scrivi: 1733184000"
echo "   4. Seleziona il numero"
echo "   5. Premi: ⌘ + ⇧ + E"
echo "   6. Vedrai la finestra con la data convertita!"
echo ""
echo "💡 SUGGERIMENTO: La prima volta dovrai autorizzare l'app in:"
echo "   Preferenze di Sistema → Privacy e Sicurezza → Accessibilità"
echo ""
