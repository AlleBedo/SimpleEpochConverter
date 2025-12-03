# 🚀 Testare SimpleEpochConverter senza Xcode

Puoi compilare ed eseguire l'app direttamente dal terminale usando il compilatore Swift!

## Prerequisiti

Devi avere installato gli **Xcode Command Line Tools** (anche senza Xcode):

```bash
xcode-select --install
```

Verifica l'installazione:
```bash
swift --version
```

## Opzione 1: Compilazione e Esecuzione Rapida (Consigliata)

### 1. Compila l'app
```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter
./build.sh
```

### 2. Esegui l'app
```bash
./run.sh
```

Oppure apri manualmente:
```bash
open build/SimpleEpochConverter.app
```

## Opzione 2: Compilazione Manuale

Se preferisci compilare manualmente senza lo script:

```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter

# Crea la struttura dell'app
mkdir -p build/SimpleEpochConverter.app/Contents/MacOS
mkdir -p build/SimpleEpochConverter.app/Contents/Resources

# Compila
swiftc -o build/SimpleEpochConverter.app/Contents/MacOS/SimpleEpochConverter \
    -framework Cocoa \
    -framework SwiftUI \
    -framework Carbon \
    -target arm64-apple-macos13.0 \
    SimpleEpochConverterApp.swift \
    ContentView.swift \
    HotKeyManager.swift \
    EpochConverter.swift \
    ResultWindow.swift

# Copia i file di configurazione
cp Info.plist build/SimpleEpochConverter.app/Contents/Info.plist
echo "APPL????" > build/SimpleEpochConverter.app/Contents/PkgInfo

# Esegui
open build/SimpleEpochConverter.app
```

## Opzione 3: Esecuzione Diretta (Solo per test veloci)

Per un test rapido senza creare l'app bundle:

```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter

swift \
    SimpleEpochConverterApp.swift \
    ContentView.swift \
    HotKeyManager.swift \
    EpochConverter.swift \
    ResultWindow.swift
```

⚠️ **Nota**: Questa opzione potrebbe non funzionare perfettamente perché l'app necessita di permessi speciali.

## 🔐 Gestione Permessi

### Prima esecuzione

Quando esegui l'app compilata senza Xcode, macOS mostrerà un avviso di sicurezza:

1. Vai su **Preferenze di Sistema** → **Privacy e Sicurezza**
2. Clicca su **"Apri comunque"** accanto al messaggio su SimpleEpochConverter
3. Conferma cliccando **"Apri"**

### Permessi di Accessibilità

L'app ti chiederà automaticamente i permessi di accessibilità:

1. Vai su **Preferenze di Sistema** → **Privacy e Sicurezza** → **Accessibilità**
2. Aggiungi **SimpleEpochConverter** alla lista
3. Attiva la spunta

## 🧪 Come testare

1. **Avvia l'app** - Vedrai un'icona di orologio nella menu bar
2. **Apri un editor di testo** o browser
3. **Scrivi un timestamp epoch**, ad esempio: `1733184000`
4. **Seleziona il numero**
5. **Premi ⌘ + ⇧ + E**
6. **Vedrai apparire la finestra** con la data convertita!

### Esempi di timestamp da testare:

```
1733184000          → 3 dicembre 2024
1701619200          → 3 dicembre 2023
1609459200          → 1 gennaio 2021
1733184000000       → 3 dicembre 2024 (millisecondi)
```

## 🐛 Risoluzione Problemi

### "command not found: swiftc"
Installa Xcode Command Line Tools:
```bash
xcode-select --install
```

### "App danneggiata" o "Impossibile aprire"
Rimuovi la quarantena:
```bash
xattr -cr build/SimpleEpochConverter.app
open build/SimpleEpochConverter.app
```

### "The application cannot be opened because its executable is missing"
Questo problema è già risolto negli script! Se lo vedi ancora:
1. Ricompila completamente: `./manage.sh rebuild`
2. Verifica l'Info.plist: `cat build/SimpleEpochConverter.app/Contents/Info.plist | grep CFBundleExecutable`
3. Vedi [FIX_EXECUTABLE_MISSING.md](FIX_EXECUTABLE_MISSING.md) per dettagli tecnici

### Lo shortcut non funziona
- Verifica di aver concesso i permessi di accessibilità
- Riavvia l'app dopo aver concesso i permessi
- Controlla che nessun'altra app usi ⌘⇧E

### L'app si chiude immediatamente
Esegui da terminale per vedere gli errori:
```bash
build/SimpleEpochConverter.app/Contents/MacOS/SimpleEpochConverter
```

## 📊 Confronto Metodi

| Metodo | Velocità | Facilità | Code Signing | Adatto per |
|--------|----------|----------|--------------|------------|
| Script build.sh | ⚡⚡⚡ | 😊😊😊 | ❌ | Testing rapido |
| Compilazione manuale | ⚡⚡ | 😊😊 | ❌ | Capire il processo |
| Esecuzione diretta | ⚡⚡⚡⚡ | 😊 | ❌ | Test velocissimi |
| Xcode | ⚡ | 😊😊😊😊 | ✅ | Distribuzione |

## 💡 Suggerimento

Per un test veloce senza preoccuparti dei permessi, puoi anche:

1. Cliccare sull'icona nella menu bar
2. Testare la conversione manualmente copiando un timestamp
3. Vedere il risultato nella finestra

Questo ti permette di verificare che la logica di conversione funzioni correttamente!
