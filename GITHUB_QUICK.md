# 🚀 Come Caricare su GitHub - Guida Rapida

## 📋 TL;DR - Comandi Veloci

```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter

# Metodo 1: Script Automatico (CONSIGLIATO)
./github-setup.sh

# Metodo 2: Manuale
git init
git add .
git commit -m "Initial commit: SimpleEpochConverter"
git remote add origin https://github.com/TUO_USERNAME/TUO_REPO.git
git branch -M main
git push -u origin main
```

---

## ✅ Prerequisiti

### 1. Crea il repository su GitHub
1. Vai su https://github.com/new
2. Nome repository: `SimpleEpochConverter` (o quello che preferisci)
3. Descrizione: `macOS menu bar app for converting epoch timestamps to readable dates`
4. **NON** inizializzare con README, .gitignore o license
5. Clicca "Create repository"

### 2. Prepara l'autenticazione

#### Opzione A: HTTPS (più semplice)
1. Vai su https://github.com/settings/tokens
2. "Generate new token (classic)"
3. Seleziona scope: `repo`
4. Copia il token (lo userai come password)

#### Opzione B: SSH (più sicuro)
```bash
# Genera chiave SSH (se non l'hai)
ssh-keygen -t rsa -b 4096 -C "tua@email.com"

# Copia la chiave pubblica
cat ~/.ssh/id_rsa.pub | pbcopy

# Vai su GitHub → Settings → SSH Keys → New SSH key
# Incolla la chiave
```

---

## 🎯 Metodo 1: Script Automatico (CONSIGLIATO)

```bash
./github-setup.sh
```

Lo script ti chiederà:
1. ✏️ Username GitHub
2. ✏️ Nome repository
3. 🔐 Metodo autenticazione (HTTPS/SSH)
4. ✅ Conferma

Poi farà tutto automaticamente! 🎉

---

## 📝 Metodo 2: Passo per Passo Manuale

### Step 1: Inizializza Git
```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter
git init
```

### Step 2: Aggiungi file
```bash
# Verifica cosa verrà aggiunto
git status

# Aggiungi tutto (esclude automaticamente build/ grazie a .gitignore)
git add .
```

### Step 3: Primo commit
```bash
git commit -m "Initial commit: SimpleEpochConverter

- macOS menu bar app for epoch timestamp conversion
- Global shortcut support (Cmd+Shift+E)
- SwiftUI interface
- Build scripts for compilation without Xcode"
```

### Step 4: Collega a GitHub
```bash
# HTTPS
git remote add origin https://github.com/TUO_USERNAME/TUO_REPO.git

# oppure SSH
git remote add origin git@github.com:TUO_USERNAME/TUO_REPO.git
```

### Step 5: Push
```bash
git branch -M main
git push -u origin main
```

---

## 🎨 Dopo il Push

### 1. Configura il repository su GitHub

**Descrizione suggerita:**
```
macOS menu bar application for converting epoch timestamps to human-readable dates with global shortcut support
```

**Topics suggeriti:**
- `swift`
- `macos`
- `epoch-converter`
- `menubar-app`
- `swiftui`
- `timestamp-converter`

### 2. Aggiungi screenshot (opzionale)

```bash
# Crea cartella
mkdir -p .github/screenshots

# Fai screenshot dell'app (Cmd+Shift+4)
# Salva in .github/screenshots/

# Aggiungi al repository
git add .github/
git commit -m "Add screenshots"
git push
```

Poi aggiorna README.md con:
```markdown
## 📸 Screenshots

![Menu Bar Icon](/.github/screenshots/menubar.png)
![Result Window](/.github/screenshots/result.png)
```

### 3. Crea una Release (opzionale)

```bash
# Crea tag
git tag -a v1.0.0 -m "Release 1.0.0 - First stable version"
git push origin v1.0.0
```

Su GitHub:
1. Vai su "Releases" → "Create a new release"
2. Seleziona tag v1.0.0
3. Titolo: "SimpleEpochConverter v1.0.0"
4. Descrizione: Lista delle funzionalità
5. Opzionale: Allega `SimpleEpochConverter.app` compilata

---

## 🔧 Comandi Utili Dopo il Setup

### Aggiornare dopo modifiche
```bash
git status                  # Vedi cosa è cambiato
git add .                   # Aggiungi modifiche
git commit -m "Descrizione" # Commit
git push                    # Push su GitHub
```

### Vedere la storia
```bash
git log --oneline           # Storia commits
git log --graph --oneline   # Storia con grafo
```

### Annullare modifiche
```bash
git restore .               # Annulla modifiche non committate
git reset --soft HEAD~1     # Annulla ultimo commit (mantiene modifiche)
```

### Sincronizzare con GitHub
```bash
git pull                    # Scarica e integra
git fetch                   # Solo scarica
```

---

## ⚠️ Cosa NON Caricare

Il `.gitignore` è già configurato per escludere:

- ❌ `build/` - App compilata (troppo grande)
- ❌ `*.xcuserdata` - Dati utente Xcode
- ❌ `.DS_Store` - File di sistema macOS
- ❌ File temporanei

✅ Tutto il resto viene caricato!

---

## 🆘 Problemi Comuni

### "remote origin already exists"
```bash
git remote remove origin
git remote add origin URL_REPOSITORY
```

### "failed to push"
```bash
# Se il repository ha contenuti
git pull origin main --rebase
git push -u origin main
```

### "Authentication failed" (HTTPS)
- Non usare la password GitHub
- Usa il Personal Access Token generato prima

### "Permission denied" (SSH)
```bash
# Verifica chiave SSH
ssh -T git@github.com
# Dovrebbe rispondere con il tuo username
```

### "Repository not found"
- Verifica che il repository esista su GitHub
- Controlla username e nome repository nell'URL

---

## 📚 File del Progetto

### Già Pronti per GitHub:
- ✅ `README.md` - Con badge!
- ✅ `LICENSE` - MIT License
- ✅ `.gitignore` - Configurato
- ✅ Codice sorgente Swift
- ✅ Script di build
- ✅ Documentazione completa

### Struttura dopo upload:
```
github.com/TUO_USERNAME/SimpleEpochConverter/
├── 📄 README.md (con badge)
├── 📄 LICENSE (MIT)
├── 📁 .github/
├── 💻 *.swift
├── 🔧 *.sh
├── 📖 *.md
├── ⚙️ *.plist
└── 🎯 .xcodeproj/
```

---

## ✅ Checklist Finale

Prima del push:

- [ ] Repository creato su GitHub
- [ ] Autenticazione configurata (token o SSH)
- [ ] `.gitignore` presente
- [ ] `LICENSE` aggiunto
- [ ] README con badge aggiornato
- [ ] Progetto compila: `./manage.sh verify`
- [ ] Nessun file sensibile nel commit

Dopo il push:

- [ ] Repository pubblico/privato impostato
- [ ] Descrizione aggiunta
- [ ] Topics aggiunti
- [ ] Screenshot caricati (opzionale)
- [ ] Release creata (opzionale)

---

## 🎉 Fatto!

Ora il tuo progetto è su GitHub! 

**URL Repository:**
```
https://github.com/TUO_USERNAME/SimpleEpochConverter
```

**Condividi con:**
- Badge nel README
- Link su social media
- Submit su awesome-macos lists
- Post su forum Swift/macOS

---

**Documentazione Completa:** [GITHUB_UPLOAD.md](GITHUB_UPLOAD.md)

**Hai bisogno di aiuto?** Vedi la sezione "Problemi Comuni" sopra
