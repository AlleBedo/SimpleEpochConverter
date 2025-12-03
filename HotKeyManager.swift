import Cocoa
import Carbon

class HotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
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
        print("Hot key premuto!")
        
        // Ottieni il testo selezionato
        if let selectedText = getSelectedText() {
            print("Testo selezionato: \(selectedText)")
            
            // Converti l'epoch
            EpochConverter.shared.convertEpoch(selectedText)
            
            // Mostra il risultato
            showResultWindow()
        } else {
            print("Nessun testo selezionato")
            showError("Seleziona un timestamp epoch prima di usare lo shortcut")
        }
    }
    
    private func getSelectedText() -> String? {
        // Salva la clipboard corrente
        let pasteboard = NSPasteboard.general
        let oldContents = pasteboard.string(forType: .string)
        
        // Simula Cmd+C per copiare il testo selezionato
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Cmd+C
        let cmdCDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        cmdCDown?.flags = .maskCommand
        let cmdCUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        cmdCUp?.flags = .maskCommand
        
        cmdCDown?.post(tap: .cghidEventTap)
        cmdCUp?.post(tap: .cghidEventTap)
        
        // Aspetta un momento per far sì che la clipboard si aggiorni
        Thread.sleep(forTimeInterval: 0.1)
        
        // Ottieni il testo copiato
        let copiedText = pasteboard.string(forType: .string)
        
        // Ripristina la clipboard originale
        if let oldContents = oldContents {
            pasteboard.clearContents()
            pasteboard.setString(oldContents, forType: .string)
        }
        
        return copiedText
    }
    
    private func showResultWindow() {
        DispatchQueue.main.async {
            // Attiva l'applicazione
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            // Mostra la finestra di risultato
            let resultWindow = ResultWindow()
            resultWindow.show()
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
