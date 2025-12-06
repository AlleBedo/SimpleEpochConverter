import SwiftUI

@main
struct SimpleEpochConverterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var hotKeyManager: HotKeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Nascondi l'icona dal dock
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Crea l'icona nella menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "Epoch Converter")
            button.action = #selector(togglePopover)
        }
        
        // Inizializza il popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 380, height: 280)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Inizializza l'hot key manager e passa il riferimento all'AppDelegate
        hotKeyManager = HotKeyManager(appDelegate: self)
        hotKeyManager?.registerHotKey()
        
        // Richiedi i permessi di accessibilità
        requestAccessibilityPermissions()
    }
    
    func showPopoverFromHotKey() {
        // Mostra il popover dalla menu bar quando viene premuto l'hotkey
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted {
            print("Accessibilità non abilitata. Richiedi i permessi nelle Preferenze di Sistema.")
        }
    }
}
