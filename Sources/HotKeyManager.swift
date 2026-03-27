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
        let settings = AppSettings.shared
        
        let hotKeySignature: UInt32 = 0x6570
        let hotKeyID = EventHotKeyID(signature: OSType(hotKeySignature), id: 1)
        
        // Use settings for modifiers and key code
        let modifiers = settings.modifierFlags
        let keyCode = settings.keyCode
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        
        // Install the event handler
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }
            
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.hotKeyPressed()
            
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        // Register the hot key
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        print("Hot key registered: \(settings.shortcutDisplayString)")
    }
    
    func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            print("Hot key unregistered")
        }
    }
    
    private func hotKeyPressed() {
        print("🔥 Hot key pressed!")
        
        // Check if we have accessibility permissions
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️  No accessibility permissions")
            showError("⚠️ Accessibility Permissions Required\n\nPlease grant permissions in:\nSystem Settings → Privacy & Security → Accessibility\n\nThen try again.")
            
            // Open System Settings
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            return
        }
        
        // Get selected text
        if let selectedText = getSelectedText() {
            print("✅ Selected text: '\(selectedText)'")
            print("📏 Length: \(selectedText.count) characters")
            
            // Convert the epoch
            EpochConverter.shared.convertEpoch(selectedText)
            
            // Show the result
            showResultWindow()
        } else {
            print("❌ No text selected or clipboard unchanged")
            let settings = AppSettings.shared
            showError("Select an epoch timestamp with your mouse\nbefore pressing \(settings.shortcutDisplayString)\n\nExample: 1733184000")
        }
    }
    
    private func getSelectedText() -> String? {
        // Save current clipboard
        let pasteboard = NSPasteboard.general
        let oldContents = pasteboard.string(forType: .string)
        let oldChangeCount = pasteboard.changeCount
        
        print("📋 Old clipboard: '\(oldContents ?? "empty")'")
        print("📊 Old change count: \(oldChangeCount)")
        
        // Clear clipboard temporarily to detect if copy worked
        pasteboard.clearContents()
        
        // Simulate Cmd+C to copy selected text
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Cmd+C
        let cmdCDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
        cmdCDown?.flags = .maskCommand
        let cmdCUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        cmdCUp?.flags = .maskCommand
        
        cmdCDown?.post(tap: .cghidEventTap)
        cmdCUp?.post(tap: .cghidEventTap)
        
        print("⌨️  Cmd+C simulated, waiting for clipboard...")

        // Poll for clipboard change with timeout
        var copiedText: String? = nil
        var newChangeCount = pasteboard.changeCount
        let deadline = Date().addingTimeInterval(0.5)
        while Date() < deadline {
            Thread.sleep(forTimeInterval: 0.02)
            newChangeCount = pasteboard.changeCount
            if newChangeCount != oldChangeCount {
                copiedText = pasteboard.string(forType: .string)
                break
            }
        }
        
        print("📋 New clipboard: '\(copiedText ?? "empty")'")
        print("📊 New change count: \(newChangeCount)")
        
        // Check if the clipboard changed
        let hasNewContent = newChangeCount != oldChangeCount && copiedText != nil && !copiedText!.isEmpty
        
        print("🔍 Has new content: \(hasNewContent)")
        
        // Restore the original clipboard
        pasteboard.clearContents()
        if let oldContents = oldContents {
            pasteboard.setString(oldContents, forType: .string)
        }
        
        // Return text only if something new was actually copied
        if hasNewContent {
            return copiedText
        }
        
        return nil
    }
    
    private func showResultWindow() {
        DispatchQueue.main.async {
            // Call the AppDelegate method to show the popover from the menu bar
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
