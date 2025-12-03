# Simple Epoch Converter

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-green.svg)

Un'applicazione macOS semplice e veloce per convertire timestamp epoch in date leggibili.

## 🎯 Caratteristiche

- **Conversione istantanea**: Seleziona un timestamp epoch ovunque sul Mac e premi lo shortcut
- **Shortcut globale**: `⌘ + ⇧ + E` (Command + Shift + E)
- **Supporto multiplo**: Gestisce sia timestamp in secondi che in millisecondi
- **Tempo relativo**: Mostra quanto tempo è passato/manca alla data
- **Menu bar icon**: Icona discreta nella barra del menu per accesso rapido
- **Copia facile**: Pulsanti per copiare sia l'epoch che la data convertita

## 🚀 Come usare

1. **Prima volta**: L'app chiederà i permessi di accessibilità. Vai su:
   - Preferenze di Sistema → Privacy e Sicurezza → Accessibilità
   - Aggiungi SimpleEpochConverter alla lista delle app autorizzate

2. **Uso normale**:
   - Seleziona un timestamp epoch in qualsiasi app (browser, editor, terminale, ecc.)
   - Premi `⌘ + ⇧ + E`
   - La finestra con il risultato apparirà automaticamente

3. **Alternative**:
   - Clicca sull'icona nella menu bar per vedere l'ultima conversione
   - Premi `ESC` o clicca "Chiudi" per chiudere la finestra del risultato

## 📋 Esempi di timestamp supportati

- **Secondi**: `1701619200` → 3 dicembre 2023
- **Millisecondi**: `1701619200000` → 3 dicembre 2023
- **Con testo**: "timestamp: 1701619200" → Estrae automaticamente il numero

## 🛠️ Compilazione

### Prerequisiti
- macOS 13.0 o superiore
- Xcode Command Line Tools (oppure Xcode 14.0+)
- Swift 5.0+

### Opzione A: Compilazione Rapida (senza Xcode) ⚡

1. Installa Xcode Command Line Tools se non li hai:
   ```bash
   xcode-select --install
   ```

2. Compila ed esegui:
   ```bash
   cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter
   ./build.sh
   ./run.sh
   ```

📖 **Guida completa**: Vedi [TESTING_WITHOUT_XCODE.md](TESTING_WITHOUT_XCODE.md) per istruzioni dettagliate

### Opzione B: Compilazione con Xcode

1. Apri il progetto in Xcode:
   ```bash
   open SimpleEpochConverter.xcodeproj
   ```

2. Seleziona il target "SimpleEpochConverter" e il tuo team di sviluppo

3. Compila ed esegui:
   - Premi `⌘ + R` oppure
   - Product → Run

### Nota sui permessi

L'app richiede i seguenti permessi:
- **Accessibilità**: Per leggere il testo selezionato
- **Apple Events**: Per simulare la combinazione Cmd+C

Questi permessi sono necessari solo per il funzionamento dello shortcut globale.

## 📁 Struttura del progetto

```
SimpleEpochConverter/
├── SimpleEpochConverterApp.swift  # App principale e AppDelegate
├── ContentView.swift              # Vista della menu bar
├── HotKeyManager.swift            # Gestione shortcut globali
├── EpochConverter.swift           # Logica di conversione
├── ResultWindow.swift             # Finestra dei risultati
├── Info.plist                     # Configurazione app
└── SimpleEpochConverter.entitlements  # Permessi richiesti
```

## 🔧 Personalizzazione

### Cambiare lo shortcut

Modifica il file `HotKeyManager.swift`, nella funzione `registerHotKey()`:

```swift
// Esempio: Cmd+Shift+T invece di Cmd+Shift+E
let modifiers = UInt32(cmdKey | shiftKey)
let keyCode: UInt32 = 17  // 't' invece di 'e' (14)
```

### Cambiare il formato della data

Modifica il file `EpochConverter.swift`, nella funzione `convertEpoch()`:

```swift
dateFormatter.dateStyle = .long  // Cambia in .short, .medium, .full
dateFormatter.timeStyle = .long  // Cambia in .short, .medium, .full
dateFormatter.locale = Locale(identifier: "it_IT")  // Cambia la lingua
```

## ⚠️ Risoluzione problemi

### Lo shortcut non funziona
- Verifica che l'app abbia i permessi di accessibilità
- Riavvia l'app dopo aver concesso i permessi
- Controlla che lo shortcut non sia in conflitto con altre app

### La finestra non appare
- Controlla la console per eventuali errori
- Verifica che il testo selezionato contenga effettivamente un numero

### L'app non legge la selezione
- Assicurati che i permessi di Apple Events siano concessi
- Verifica che il testo sia effettivamente selezionato prima di premere lo shortcut

## 📝 Licenza

Questo progetto è rilasciato sotto licenza MIT. Sei libero di usarlo, modificarlo e distribuirlo.

## 👤 Autore

Alessandro Bedini

## 🙏 Contributi

Contributi, issues e feature requests sono benvenuti!
