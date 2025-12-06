import Cocoa
import Carbon

class HotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private weak var appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func registerHotKey() {
        // Registra Cmd+Shift+E
        let hotKeySignature: UInt32 = 0x6570
        let hotKeyID = EventHotKeyID(signature: OSType(hotKeySignature), id: 1)
        
        // Cmd (⌘) = cmdKey, Shift (⇧) = shiftKey
        let modifiers = UInt32(cmdKey | shiftKey)
        
        // 'e' key code
        let keyCode: UInt32 = 14
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        
        // Installa l'event handler
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.hotKeyPressed()
            
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        // Registra l'hot key
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        print("Hot key registrato: ⌘ + ⇧ + E")
    }
    
    private func hotKeyPressed() {
        print("🔥 Hot key premuto!")
        
        // Ottieni il testo selezionato
        if let selectedText = getSelectedText() {
            print("✅ Testo selezionato: '\(selectedText)'")
            print("📏 Lunghezza: \(selectedText.count) caratteri")
            
            // Converti l'epoch
            EpochConverter.shared.convertEpoch(selectedText)
            
            // Mostra il risultato
            showResultWindow()
        } else {
            print("❌ Nessun testo selezionato o clipboard non cambiata")
            showError("Seleziona un timestamp epoch con il mouse\nprima di premere ⌘ + ⇧ + E\n\nEsempio: 1733184000")
        }
    }
    
    private func getSelectedText() -> String? {
        // Salva la clipboard corrente
        let pasteboard = NSPasteboard.general
        let oldContents = pasteboard.string(forType: .string)
        let oldChangeCount = pasteboard.changeCount
        
        print("📋 Old clipboard: '\(oldContents ?? "empty")'")
        print("📊 Old change count: \(oldChangeCount)")
        
        // Pulisci la clipboard temporaneamente per rilevare se la copia ha funzionato
        pasteboard.clearContents()
        
        // Simula Cmd+C per copiare il testo selezionato
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Cmd+C
        let cmdCDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        cmdCDown?.flags = .maskCommand
        let cmdCUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        cmdCUp?.flags = .maskCommand
        
        cmdCDown?.post(tap: .cghidEventTap)
        cmdCUp?.post(tap: .cghidEventTap)
        
        print("⌨️  Cmd+C simulato, aspetto 0.2s...")
        
        // Aspetta che la clipboard si aggiorni (aumentato il tempo)
        Thread.sleep(forTimeInterval: 0.2)
        
        // Ottieni il testo copiato
        let copiedText = pasteboard.string(forType: .string)
        let newChangeCount = pasteboard.changeCount
        
        print("📋 New clipboard: '\(copiedText ?? "empty")'")
        print("📊 New change count: \(newChangeCount)")
        
        // Verifica se la clipboard è cambiata
        let hasNewContent = newChangeCount != oldChangeCount && copiedText != nil && !copiedText!.isEmpty
        
        print("🔍 Has new content: \(hasNewContent)")
        
        // Ripristina la clipboard originale
        pasteboard.clearContents()
        if let oldContents = oldContents {
            pasteboard.setString(oldContents, forType: .string)
        }
        
        // Ritorna il testo solo se effettivamente copiato qualcosa di nuovo
        if hasNewContent {
            return copiedText
        }
        
        return nil
    }
    
    private func showResultWindow() {
        DispatchQueue.main.async {
            // Chiama il metodo dell'AppDelegate per mostrare il popover dalla menu bar
            self.appDelegate?.showPopoverFromHotKey()
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Epoch Converter"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    deinit {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
