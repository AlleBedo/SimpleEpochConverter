# 📚 Documentazione SimpleEpochConverter

Benvenuto! Questo progetto include diverse guide per aiutarti. Scegli quella più adatta alle tue esigenze:

## 🚀 Inizio Rapido

**Vuoi iniziare subito?**
👉 **[QUICK_START.md](QUICK_START.md)** - Guida veloce in 3 passaggi

```bash
./manage.sh test
```

---

## 📖 Guide Complete

### 🎯 Per utenti base
- **[README.md](README.md)** - Documentazione principale completa
  - Caratteristiche
  - Come usare l'app
  - Esempi
  - Personalizzazione

### 💻 Per sviluppatori senza Xcode
- **[TESTING_WITHOUT_XCODE.md](TESTING_WITHOUT_XCODE.md)** - Guida dettagliata
  - Compilazione da terminale
  - Opzioni di build
  - Troubleshooting
  - Architetture supportate

### ✅ Risultati e conferme
- **[TEST_SUCCESS.md](TEST_SUCCESS.md)** - Conferma test completati
  - Stato compilazione
  - Istruzioni post-build
  - Esempi di utilizzo

---

## 🛠️ Strumenti e Script

### Script principale (consigliato)
```bash
./manage.sh help
```

Comandi disponibili:
- `build` - Compila l'app
- `run` - Esegue l'app  
- `test` - Test completo
- `status` - Verifica stato
- `restart` - Riavvia l'app
- `logs` - Mostra log
- `clean` - Pulisce build

### Altri script utili
- `build.sh` - Solo compilazione
- `run.sh` - Solo esecuzione
- `quick-test.sh` - Build + run guidato

---

## 📂 Struttura File

```
SimpleEpochConverter/
│
├── 📖 Documentazione
│   ├── README.md                    # Guida principale
│   ├── QUICK_START.md               # Inizio rapido
│   ├── TESTING_WITHOUT_XCODE.md     # Testing senza Xcode
│   ├── TEST_SUCCESS.md              # Conferma test
│   └── INDEX.md                     # Questo file
│
├── 🔧 Script
│   ├── manage.sh                    # Gestore principale ⭐
│   ├── build.sh                     # Script build
│   ├── run.sh                       # Script run
│   └── quick-test.sh                # Test veloce
│
├── 💻 Codice Sorgente
│   ├── SimpleEpochConverterApp.swift  # App principale
│   ├── ContentView.swift              # Vista menu bar
│   ├── HotKeyManager.swift            # Gestione shortcut
│   ├── EpochConverter.swift           # Logica conversione
│   └── ResultWindow.swift             # Finestra risultati
│
├── ⚙️ Configurazione
│   ├── Info.plist                   # Config app
│   ├── SimpleEpochConverter.entitlements
│   ├── SimpleEpochConverter.xcodeproj/
│   └── .gitignore
│
└── 📦 Output
    └── build/
        └── SimpleEpochConverter.app # App compilata
```

---

## 🎯 Percorsi Suggeriti

### 👤 Sono un utente normale
1. [QUICK_START.md](QUICK_START.md) - Parti da qui!
2. [README.md](README.md) - Per sapere di più
3. Usa `./manage.sh test` per compilare ed eseguire

### 💻 Sono uno sviluppatore
1. [TESTING_WITHOUT_XCODE.md](TESTING_WITHOUT_XCODE.md) - Guida tecnica completa
2. [README.md](README.md) - Architettura e personalizzazione
3. Esplora il codice sorgente `.swift`

### 🚀 Voglio solo provare l'app
```bash
cd /Users/alessandrobedini/CodeProjects/SimpleEpochConverter
./manage.sh test
```

Poi leggi [TEST_SUCCESS.md](TEST_SUCCESS.md) per istruzioni d'uso.

---

## ❓ FAQ

**D: Serve Xcode?**  
R: No! Servono solo gli Xcode Command Line Tools (`xcode-select --install`)

**D: Quale guida devo leggere?**  
R: Inizia da [QUICK_START.md](QUICK_START.md)

**D: Come compilo l'app?**  
R: `./manage.sh build` oppure `./build.sh`

**D: Come la eseguo?**  
R: `./manage.sh run` oppure `./run.sh`

**D: Quale script uso?**  
R: Usa `./manage.sh` - è il più completo!

**D: Dove trovo l'app compilata?**  
R: In `build/SimpleEpochConverter.app`

**D: Come funziona lo shortcut?**  
R: Seleziona un timestamp e premi ⌘⇧E

**D: Non funziona!**  
R: Leggi la sezione troubleshooting in [TESTING_WITHOUT_XCODE.md](TESTING_WITHOUT_XCODE.md)

---

## 🆘 Aiuto Rapido

```bash
# Tutto in un comando
./manage.sh help

# Test completo
./manage.sh test

# Verifica stato
./manage.sh status

# Vedi i log
./manage.sh logs
```

---

## 🎉 Fatto!

Ora hai tutto quello che ti serve. Buon divertimento con **SimpleEpochConverter**!

**Ricorda**: Per domande veloci, usa `./manage.sh help`

---

📅 Ultima revisione: 3 dicembre 2025
