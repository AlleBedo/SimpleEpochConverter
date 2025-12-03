#!/bin/bash

# Script di gestione per SimpleEpochConverter
# Uso: ./manage.sh [comando]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_BUNDLE="$SCRIPT_DIR/build/SimpleEpochConverter.app"

# Colori
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  SimpleEpochConverter - Gestione App${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Uso: ./manage.sh [comando]"
    echo ""
    echo "Comandi disponibili:"
    echo ""
    echo -e "  ${GREEN}build${NC}      Compila l'applicazione"
    echo -e "  ${GREEN}run${NC}        Esegue l'applicazione"
    echo -e "  ${GREEN}rebuild${NC}    Ricompila completamente (clean + build)"
    echo -e "  ${GREEN}stop${NC}       Ferma l'applicazione"
    echo -e "  ${GREEN}restart${NC}    Riavvia l'applicazione (stop + run)"
    echo -e "  ${GREEN}status${NC}     Verifica se l'app è in esecuzione"
    echo -e "  ${GREEN}verify${NC}     Verifica che l'app sia compilata correttamente"
    echo -e "  ${GREEN}clean${NC}      Rimuove i file compilati"
    echo -e "  ${GREEN}logs${NC}       Mostra i log dell'app"
    echo -e "  ${GREEN}test${NC}       Test rapido completo (rebuild + run)"
    echo -e "  ${GREEN}help${NC}       Mostra questo messaggio"
    echo ""
    echo "Esempi:"
    echo "  ./manage.sh build      # Compila l'app"
    echo "  ./manage.sh run        # Esegue l'app"
    echo "  ./manage.sh test       # Build e run in un comando"
    echo ""
}

cmd_build() {
    echo -e "${BLUE}🔨 Compilazione...${NC}"
    "$SCRIPT_DIR/build.sh"
}

cmd_run() {
    if [ ! -d "$APP_BUNDLE" ]; then
        echo -e "${RED}❌ App non compilata. Esegui prima: ./manage.sh build${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}🚀 Avvio app...${NC}"
    open "$APP_BUNDLE"
    sleep 1
    
    if pgrep -f "SimpleEpochConverter" > /dev/null; then
        echo -e "${GREEN}✅ App avviata con successo!${NC}"
        echo -e "${BLUE}💡 Cerca l'icona dell'orologio nella menu bar${NC}"
    else
        echo -e "${YELLOW}⚠️  App avviata, attendi qualche secondo...${NC}"
    fi
}

cmd_stop() {
    echo -e "${YELLOW}⏹  Arresto app...${NC}"
    if pgrep -f "SimpleEpochConverter" > /dev/null; then
        killall SimpleEpochConverter 2>/dev/null || true
        echo -e "${GREEN}✅ App fermata${NC}"
    else
        echo -e "${BLUE}ℹ️  App non in esecuzione${NC}"
    fi
}

cmd_status() {
    echo -e "${BLUE}📊 Stato SimpleEpochConverter${NC}"
    echo ""
    
    # Verifica compilazione
    if [ -d "$APP_BUNDLE" ]; then
        echo -e "  Compilazione: ${GREEN}✅ OK${NC}"
        BINARY="$APP_BUNDLE/Contents/MacOS/SimpleEpochConverter"
        if [ -x "$BINARY" ]; then
            SIZE=$(ls -lh "$BINARY" | awk '{print $5}')
            echo -e "  Dimensione:   ${BLUE}$SIZE${NC}"
        fi
    else
        echo -e "  Compilazione: ${RED}❌ Non compilata${NC}"
    fi
    
    # Verifica esecuzione
    if pgrep -f "SimpleEpochConverter" > /dev/null; then
        PID=$(pgrep -f "SimpleEpochConverter")
        echo -e "  Esecuzione:   ${GREEN}✅ In esecuzione (PID: $PID)${NC}"
    else
        echo -e "  Esecuzione:   ${YELLOW}⏸  Non in esecuzione${NC}"
    fi
    
    echo ""
}

cmd_clean() {
    echo -e "${YELLOW}🧹 Pulizia file compilati...${NC}"
    rm -rf "$SCRIPT_DIR/build"
    echo -e "${GREEN}✅ Pulizia completata${NC}"
}

cmd_rebuild() {
    cmd_clean
    cmd_build
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_run
}

cmd_logs() {
    echo -e "${BLUE}📋 Log dell'applicazione${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if pgrep -f "SimpleEpochConverter" > /dev/null; then
        echo -e "${GREEN}App in esecuzione. Eseguendo da terminale per vedere i log...${NC}"
        echo ""
        cmd_stop
        sleep 1
        "$APP_BUNDLE/Contents/MacOS/SimpleEpochConverter"
    else
        echo -e "${YELLOW}App non in esecuzione. Avvio con log...${NC}"
        echo ""
        "$APP_BUNDLE/Contents/MacOS/SimpleEpochConverter"
    fi
}

cmd_test() {
    echo -e "${BLUE}🧪 Test completo${NC}"
    echo ""
    cmd_rebuild
    echo ""
    cmd_run
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Test completato!${NC}"
    echo ""
    echo -e "${BLUE}Prova ora:${NC}"
    echo "  1. Apri un editor di testo"
    echo "  2. Scrivi: 1733184000"
    echo "  3. Seleziona il numero"
    echo "  4. Premi: ⌘ + ⇧ + E"
    echo ""
}

cmd_verify() {
    echo -e "${BLUE}🔍 Verifica app...${NC}"
    "$SCRIPT_DIR/verify.sh"
}

# Main
case "${1:-help}" in
    build)
        cmd_build
        ;;
    run)
        cmd_run
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    rebuild)
        cmd_rebuild
        ;;
    status)
        cmd_status
        ;;
    verify)
        cmd_verify
        ;;
    clean)
        cmd_clean
        ;;
    logs)
        cmd_logs
        ;;
    test)
        cmd_test
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Comando sconosciuto: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
