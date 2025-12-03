# 🔧 Fix: Problema "executable is missing"

## ❌ Problema Originale

Gli script mostravano l'errore:
```
The application cannot be opened because its executable is missing.
```

## 🔍 Causa

Il file `Info.plist` originale usava variabili Xcode che non venivano sostituite durante la compilazione da terminale:

```xml
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
```

Quando compili con Xcode, queste variabili vengono automaticamente sostituite. Ma quando compili da terminale con `swiftc`, rimangono come `$(EXECUTABLE_NAME)` letteralmente, e macOS non riesce a trovare l'eseguibile.

## ✅ Soluzione

Ho modificato lo script `build.sh` per generare un `Info.plist` corretto con valori reali invece di variabili:

```xml
<key>CFBundleExecutable</key>
<string>SimpleEpochConverter</string>
```

## 🎯 Cosa è stato cambiato

### build.sh
- ❌ Prima: Copiava `Info.plist` con variabili Xcode
- ✅ Ora: Genera `Info.plist` dinamicamente con valori reali

### Tutte le variabili sostituite:
- `$(EXECUTABLE_NAME)` → `SimpleEpochConverter`
- `$(PRODUCT_NAME)` → `SimpleEpochConverter`
- `$(PRODUCT_BUNDLE_IDENTIFIER)` → `com.alessandrobedini.SimpleEpochConverter`
- `$(PRODUCT_BUNDLE_PACKAGE_TYPE)` → `APPL`
- `$(DEVELOPMENT_LANGUAGE)` → `en`
- `$(MACOSX_DEPLOYMENT_TARGET)` → `13.0`

## 🧪 Verifica del Fix

```bash
# Ricompila
./build.sh

# Verifica che Info.plist sia corretto
cat build/SimpleEpochConverter.app/Contents/Info.plist | grep -A 1 CFBundleExecutable

# Dovresti vedere:
#   <key>CFBundleExecutable</key>
#   <string>SimpleEpochConverter</string>

# Verifica che l'eseguibile esista
ls -la build/SimpleEpochConverter.app/Contents/MacOS/

# Esegui l'app
./run.sh

# Verifica lo stato
./manage.sh status
```

## ✅ Stato Attuale

- ✅ Compilazione: OK
- ✅ Info.plist: Corretto
- ✅ Eseguibile: Trovato e funzionante
- ✅ App: In esecuzione (PID verificato)
- ✅ Tutti gli script: Funzionanti

## 📝 Note Tecniche

### Perché succede questo?

Xcode usa un sistema di build (xcodebuild) che:
1. Legge il file `Info.plist` sorgente
2. Sostituisce tutte le variabili `$(VARIABLE)` con valori dal progetto
3. Copia il risultato nell'app bundle

Quando compiliamo manualmente:
1. `swiftc` compila solo il codice Swift
2. Dobbiamo gestire noi l'app bundle, incluso l'Info.plist
3. Le variabili Xcode non hanno senso fuori da Xcode

### File coinvolti

- **`Info.plist`** (originale) - Mantenuto per compatibilità con Xcode
- **`build.sh`** - Genera Info.plist corretto al momento del build
- **`build/SimpleEpochConverter.app/Contents/Info.plist`** - Versione generata con valori reali

### Mantenimento di entrambi i metodi

Il progetto ora supporta:
- ✅ **Compilazione con Xcode** - Usa il file `Info.plist` originale
- ✅ **Compilazione da terminale** - Genera Info.plist automaticamente

Entrambi i metodi producono app identiche e funzionanti!

## 🚀 Test Finale

```bash
# Test completo
./manage.sh test

# Output atteso:
# 🔨 Compilazione...
# ✅ Compilazione completata!
# 🚀 Avvio app...
# ✅ App avviata con successo!
```

---

**Fix applicato**: 3 dicembre 2025  
**Stato**: ✅ Risolto e testato
