#!/bin/bash

# Script per eseguire SimpleEpochConverter
# Uso: ./run.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BUNDLE="$SCRIPT_DIR/build/SimpleEpochConverter.app"

# Verifica se l'app è stata compilata
if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App non trovata. Esegui prima ./build.sh"
    exit 1
fi

echo "🚀 Avvio SimpleEpochConverter..."
open "$APP_BUNDLE"
