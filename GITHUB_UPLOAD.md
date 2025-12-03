# 📤 Guida: Caricare su GitHub

## 🎯 Preparazione del Progetto

### 1. Inizializza Git (se non già fatto)

```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter

# Inizializza repository git
git init

# Verifica che .gitignore esista (è già presente nel progetto)
cat .gitignore
```

### 2. Aggiungi i File al Repository

```bash
# Aggiungi tutti i file (esclude automaticamente ciò che è in .gitignore)
git add .

# Verifica cosa verrà committato
git status

# Crea il primo commit
git commit -m "Initial commit: SimpleEpochConverter - macOS Epoch to Date converter"
```

### 3. Collega al Repository GitHub Esistente

```bash
# Sostituisci <username> e <repository> con i tuoi valori
git remote add origin https://github.com/<username>/<repository>.git

# Oppure se usi SSH:
# git remote add origin git@github.com:<username>/<repository>.git

# Verifica il remote
git remote -v
```

### 4. Push sul Repository

```bash
# Se il repository è vuoto:
git branch -M main
git push -u origin main

# Se il repository esiste già con contenuti:
git pull origin main --rebase
git push -u origin main
```

---

## 🚀 Script Automatico

Ho creato uno script che fa tutto questo per te:

```bash
./github-setup.sh
```

Lo script ti chiederà:
1. Username GitHub
2. Nome del repository
3. Se usare HTTPS o SSH

---

## 📋 Cosa Verrà Caricato

### ✅ File inclusi:
- Codice sorgente Swift (`*.swift`)
- Script di build (`build.sh`, `run.sh`, `manage.sh`, ecc.)
- Documentazione (`README.md`, `*.md`)
- Configurazione (`Info.plist`, `*.entitlements`)
- Progetto Xcode (`*.xcodeproj/`)
- `.gitignore`

### ❌ File esclusi (da .gitignore):
- `build/` - App compilata
- `*.xcuserdata` - Dati utente Xcode
- `.DS_Store` - File di sistema macOS
- File temporanei e cache

---

## 🔐 Autenticazione GitHub

### Opzione A: HTTPS (consigliato per semplicità)

Usa un **Personal Access Token** invece della password:

1. Vai su GitHub → Settings → Developer settings → Personal access tokens
2. Genera un nuovo token (classic)
3. Seleziona scope: `repo` (full control)
4. Copia il token
5. Quando Git chiede la password, usa il token

### Opzione B: SSH (consigliato per sicurezza)

Se hai già configurato SSH:
```bash
# Verifica chiave SSH
ls -la ~/.ssh/id_rsa.pub

# Se non esiste, creala:
ssh-keygen -t rsa -b 4096 -C "tua@email.com"

# Aggiungi a GitHub
cat ~/.ssh/id_rsa.pub
# Copia l'output e aggiungilo su GitHub → Settings → SSH Keys
```

---

## 📝 Commit Message Suggeriti

### Per il primo commit:
```bash
git commit -m "Initial commit: SimpleEpochConverter

- macOS menu bar app for epoch timestamp conversion
- Global shortcut support (Cmd+Shift+E)
- SwiftUI interface with floating result window
- Support for seconds and milliseconds
- Build scripts for compilation without Xcode
- Comprehensive documentation in Italian"
```

### Per commit successivi:
```bash
# Fix
git commit -m "Fix: risolto problema executable missing in Info.plist"

# Feature
git commit -m "Feature: aggiunto script di verifica automatica"

# Documentation
git commit -m "Docs: aggiunta guida per upload su GitHub"
```

---

## 🎨 README su GitHub

Il tuo `README.md` è già perfetto per GitHub! Include:
- ✅ Descrizione chiara
- ✅ Screenshot delle funzionalità (potresti aggiungere immagini)
- ✅ Istruzioni di installazione
- ✅ Esempi di utilizzo
- ✅ Badge (puoi aggiungerne)

### Badge suggeriti da aggiungere in cima al README:

```markdown
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-green.svg)
```

---

## 📸 Screenshot (Opzionale ma Consigliato)

Crea una cartella per screenshot:

```bash
mkdir -p .github/screenshots
```

Poi aggiungi al README:
```markdown
## 📸 Screenshots

![Menu Bar](/.github/screenshots/menubar.png)
![Result Window](/.github/screenshots/result.png)
```

---

## 🔄 Workflow Consigliato

### Dopo modifiche:

```bash
# 1. Verifica modifiche
git status

# 2. Aggiungi file modificati
git add .

# 3. Commit con messaggio descrittivo
git commit -m "Descrizione delle modifiche"

# 4. Push su GitHub
git push
```

### Per creare una release:

```bash
# Crea un tag
git tag -a v1.0.0 -m "Release 1.0.0 - Prima versione stabile"

# Push del tag
git push origin v1.0.0
```

Poi su GitHub:
1. Vai su "Releases"
2. "Create a new release"
3. Allega il file `.app` compilato (opzionale)

---

## ⚠️ Note Importanti

### Prima del push:

1. **Verifica .gitignore**: Non caricare l'app compilata
   ```bash
   # Controlla che build/ sia ignorato
   git status | grep build
   # Non dovrebbe mostrare nulla
   ```

2. **Rimuovi dati sensibili**: 
   - Token
   - Password
   - Informazioni personali

3. **Testa la compilazione**:
   ```bash
   ./manage.sh test
   ./manage.sh verify
   ```

### Struttura suggerita per GitHub:

```
Repository Root/
├── .github/
│   ├── workflows/          # CI/CD (opzionale)
│   └── screenshots/        # Immagini per README
├── *.swift                 # Codice sorgente
├── *.sh                    # Script
├── *.md                    # Documentazione
├── .gitignore
├── LICENSE                 # Aggiungi una licenza (MIT consigliata)
└── README.md
```

---

## 📄 Aggiungere una Licenza

Crea il file `LICENSE`:

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Alessandro Bedini

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

---

## 🎉 Comandi Rapidi

```bash
# Setup completo
./github-setup.sh

# Oppure manualmente:
git init
git add .
git commit -m "Initial commit: SimpleEpochConverter"
git remote add origin https://github.com/USERNAME/REPO.git
git branch -M main
git push -u origin main
```

---

## 📞 Aiuto

Se hai problemi:

```bash
# Controlla lo stato
git status

# Vedi l'history
git log --oneline

# Controlla i remote
git remote -v

# Annulla modifiche non committate
git restore .

# Rimuovi l'ultimo commit (mantiene le modifiche)
git reset --soft HEAD~1
```

---

**Pronto per il push! 🚀**
