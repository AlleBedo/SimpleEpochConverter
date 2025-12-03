#!/bin/bash

# Script per configurare e caricare il progetto su GitHub
# Uso: ./github-setup.sh

set -e

# Colori
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  SimpleEpochConverter - Setup GitHub${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verifica che git sia installato
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git non trovato. Installa git prima di continuare.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git trovato: $(git --version)${NC}"
echo ""

# Chiedi informazioni
echo -e "${BLUE}📝 Informazioni Repository${NC}"
echo ""
read -p "Username GitHub: " GITHUB_USER
read -p "Nome Repository: " REPO_NAME
echo ""

echo -e "${BLUE}🔐 Metodo di autenticazione:${NC}"
echo "  1) HTTPS (usa Personal Access Token)"
echo "  2) SSH (usa chiave SSH)"
read -p "Scegli (1 o 2): " AUTH_METHOD

if [ "$AUTH_METHOD" = "1" ]; then
    REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    REMOTE_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"
fi

echo ""
echo -e "${BLUE}🔍 Configurazione:${NC}"
echo "  Username: $GITHUB_USER"
echo "  Repository: $REPO_NAME"
echo "  URL: $REMOTE_URL"
echo ""

read -p "Confermi? (s/n): " CONFIRM
if [ "$CONFIRM" != "s" ]; then
    echo -e "${YELLOW}❌ Operazione annullata${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Inizio setup...${NC}"
echo ""

# Step 1: Inizializza git (se non già fatto)
if [ ! -d .git ]; then
    echo -e "${BLUE}1️⃣  Inizializzazione repository git...${NC}"
    git init
    echo -e "${GREEN}✅ Repository inizializzato${NC}"
else
    echo -e "${GREEN}✅ Repository git già esistente${NC}"
fi

# Step 2: Verifica .gitignore
echo ""
echo -e "${BLUE}2️⃣  Verifica .gitignore...${NC}"
if [ -f .gitignore ]; then
    echo -e "${GREEN}✅ .gitignore presente${NC}"
else
    echo -e "${YELLOW}⚠️  Creazione .gitignore...${NC}"
    cat > .gitignore << 'EOF'
# Build
build/
*.app

# Xcode
xcuserdata/
*.xcscmblueprint
*.xccheckout
DerivedData/
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3

# macOS
.DS_Store
EOF
    echo -e "${GREEN}✅ .gitignore creato${NC}"
fi

# Step 3: Aggiungi file
echo ""
echo -e "${BLUE}3️⃣  Aggiunta file al repository...${NC}"
git add .
echo -e "${GREEN}✅ File aggiunti${NC}"

# Mostra cosa verrà committato
echo ""
echo -e "${BLUE}📋 File da committare:${NC}"
git status --short | head -20
if [ $(git status --short | wc -l) -gt 20 ]; then
    echo "... e altri $(( $(git status --short | wc -l) - 20 )) file"
fi

# Step 4: Commit
echo ""
echo -e "${BLUE}4️⃣  Creazione commit...${NC}"
git commit -m "Initial commit: SimpleEpochConverter

- macOS menu bar app for epoch timestamp conversion
- Global shortcut support (Cmd+Shift+E)
- SwiftUI interface with floating result window
- Support for seconds and milliseconds
- Build scripts for compilation without Xcode
- Comprehensive documentation in Italian" 2>/dev/null || echo -e "${YELLOW}ℹ️  Commit già presente o nessuna modifica${NC}"
echo -e "${GREEN}✅ Commit creato${NC}"

# Step 5: Configura remote
echo ""
echo -e "${BLUE}5️⃣  Configurazione remote...${NC}"
if git remote | grep -q origin; then
    echo -e "${YELLOW}⚠️  Remote 'origin' già esistente. Rimozione...${NC}"
    git remote remove origin
fi
git remote add origin "$REMOTE_URL"
echo -e "${GREEN}✅ Remote configurato${NC}"

# Step 6: Verifica branch
echo ""
echo -e "${BLUE}6️⃣  Configurazione branch main...${NC}"
git branch -M main
echo -e "${GREEN}✅ Branch main configurato${NC}"

# Step 7: Push
echo ""
echo -e "${BLUE}7️⃣  Push su GitHub...${NC}"
echo ""
echo -e "${YELLOW}Nota: Se usi HTTPS, ti verrà chiesto username e token.${NC}"
echo -e "${YELLOW}      Se usi SSH, assicurati che la chiave sia configurata.${NC}"
echo ""

# Prova il push
if git push -u origin main 2>&1 | tee /tmp/git_push_output.txt; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Push completato con successo!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}🎉 Il tuo progetto è ora su GitHub:${NC}"
    echo -e "   ${GREEN}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
    echo ""
    echo -e "${BLUE}📝 Prossimi passi suggeriti:${NC}"
    echo "   1. Visita il repository su GitHub"
    echo "   2. Aggiungi una descrizione al repository"
    echo "   3. Aggiungi topics: swift, macos, epoch-converter, menubar-app"
    echo "   4. Crea una release (opzionale)"
    echo "   5. Aggiungi screenshot nella cartella .github/screenshots/"
    echo ""
else
    PUSH_ERROR=$(cat /tmp/git_push_output.txt 2>/dev/null)
    
    # Controlla se l'errore è dovuto a file esistenti nel repository remoto
    if echo "$PUSH_ERROR" | grep -q "rejected\|fetch first\|non-fast-forward"; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  Il repository remoto contiene già dei file${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${BLUE}Questo succede quando hai inizializzato il repository con:${NC}"
        echo "  - README.md"
        echo "  - LICENSE"
        echo "  - .gitignore"
        echo ""
        echo -e "${BLUE}💡 Soluzione: Integrare i file remoti${NC}"
        echo ""
        read -p "Vuoi integrare automaticamente? (s/n): " AUTO_MERGE
        
        if [ "$AUTO_MERGE" = "s" ]; then
            echo ""
            echo -e "${BLUE}🔄 Integrazione file remoti...${NC}"
            
            # Pull con allow-unrelated-histories
            if git pull origin main --allow-unrelated-histories --no-edit; then
                echo -e "${GREEN}✅ Integrazione completata${NC}"
                echo ""
                
                # Controlla se ci sono conflitti
                if git diff --name-only --diff-filter=U | grep -q .; then
                    echo -e "${YELLOW}⚠️  Conflitti rilevati nei file:${NC}"
                    git diff --name-only --diff-filter=U
                    echo ""
                    echo -e "${BLUE}Come vuoi risolverli?${NC}"
                    echo "  1) Tieni i miei file locali (CONSIGLIATO)"
                    echo "  2) Tieni i file di GitHub"
                    echo "  3) Risolvi manualmente"
                    read -p "Scegli (1, 2 o 3): " CONFLICT_CHOICE
                    
                    CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
                    
                    if [ "$CONFLICT_CHOICE" = "1" ]; then
                        echo ""
                        echo -e "${BLUE}📝 Uso file locali...${NC}"
                        for file in $CONFLICT_FILES; do
                            git checkout --ours "$file"
                            git add "$file"
                            echo -e "${GREEN}  ✅ $file${NC}"
                        done
                        git commit -m "Merge: use local project files"
                        echo -e "${GREEN}✅ Conflitti risolti${NC}"
                    elif [ "$CONFLICT_CHOICE" = "2" ]; then
                        echo ""
                        echo -e "${BLUE}📝 Uso file di GitHub...${NC}"
                        for file in $CONFLICT_FILES; do
                            git checkout --theirs "$file"
                            git add "$file"
                            echo -e "${GREEN}  ✅ $file${NC}"
                        done
                        git commit -m "Merge: use remote files"
                        echo -e "${GREEN}✅ Conflitti risolti${NC}"
                    else
                        echo ""
                        echo -e "${YELLOW}📝 Risolvi manualmente i conflitti:${NC}"
                        echo ""
                        echo "  1. Apri i file in conflitto e cerca <<<<<<< ======= >>>>>>>"
                        echo "  2. Modifica come preferisci"
                        echo "  3. Salva i file"
                        echo "  4. Esegui:"
                        echo "       git add ."
                        echo "       git commit -m 'Resolve merge conflicts'"
                        echo "       git push -u origin main"
                        echo ""
                        exit 0
                    fi
                fi
                
                # Riprova il push
                echo ""
                echo -e "${BLUE}🚀 Push finale...${NC}"
                if git push -u origin main; then
                    echo ""
                    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "${GREEN}✅ Push completato con successo!${NC}"
                    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo ""
                    echo -e "${BLUE}🎉 Il tuo progetto è ora su GitHub:${NC}"
                    echo -e "   ${GREEN}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
                    echo ""
                else
                    echo -e "${RED}❌ Errore durante il push finale${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}❌ Errore durante l'integrazione${NC}"
                exit 1
            fi
        else
            echo ""
            echo -e "${BLUE}📖 Istruzioni manuali:${NC}"
            echo ""
            echo "  1. Integra i file remoti:"
            echo "       git pull origin main --allow-unrelated-histories"
            echo ""
            echo "  2. Se ci sono conflitti, risolvili:"
            echo "       git checkout --ours FILE    # usa il tuo"
            echo "       git checkout --theirs FILE  # usa quello remoto"
            echo ""
            echo "  3. Completa il merge:"
            echo "       git add ."
            echo "       git commit -m 'Merge remote repository'"
            echo ""
            echo "  4. Push:"
            echo "       git push -u origin main"
            echo ""
            echo -e "${BLUE}📚 Vedi guida completa:${NC}"
            echo "       cat GITHUB_EXISTING_REPO.md"
            echo ""
            exit 0
        fi
    else
        # Altro tipo di errore
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ Errore durante il push${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}Possibili cause:${NC}"
        echo "  1. Repository non esiste su GitHub"
        echo "     → Crea il repository prima: https://github.com/new"
        echo ""
        echo "  2. Autenticazione fallita"
        echo "     → HTTPS: Usa un Personal Access Token invece della password"
        echo "     → SSH: Verifica che la chiave SSH sia configurata"
        echo ""
        echo -e "${BLUE}📚 Per aiuto dettagliato, vedi:${NC}"
        echo "   cat GITHUB_UPLOAD.md"
        echo "   cat GITHUB_EXISTING_REPO.md"
        echo ""
        exit 1
    fi
fi

# Step 8: Informazioni finali
echo -e "${BLUE}💡 Comandi utili:${NC}"
echo ""
echo "   # Aggiornare il repository dopo modifiche:"
echo "   git add ."
echo "   git commit -m \"Descrizione modifiche\""
echo "   git push"
echo ""
echo "   # Vedere lo stato:"
echo "   git status"
echo ""
echo "   # Creare una release:"
echo "   git tag -a v1.0.0 -m \"Release 1.0.0\""
echo "   git push origin v1.0.0"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
