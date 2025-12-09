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
        // Hide dock icon
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Create menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // Try to load custom SVG icon from Resources
            if let resourcePath = Bundle.main.resourcePath,
               let image = NSImage(contentsOfFile: resourcePath + "/spiral.svg") {
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = true
                button.image = image
            } else {
                // Fallback to system icon
                button.image = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "Epoch Converter")
            }
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Initialize popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 380, height: 280)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        // Initialize hot key manager
        hotKeyManager = HotKeyManager(appDelegate: self)
        hotKeyManager?.registerHotKey()
        
        // Request accessibility permissions
        requestAccessibilityPermissions()
        
        // Listen for shortcut changes
        NotificationCenter.default.addObserver(self, selector: #selector(shortcutChanged), name: NSNotification.Name("ShortcutChanged"), object: nil)
    }
    
    @objc func shortcutChanged() {
        hotKeyManager?.unregisterHotKey()
        hotKeyManager?.registerHotKey()
    }
    
    func showPopoverFromHotKey() {
        // Show popover from menu bar when hotkey is pressed
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        
        // Right click shows settings menu
        if event.type == .rightMouseUp {
            showContextMenu()
            return
        }
        
        // Left click toggles popover
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func showContextMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Show Last Conversion", action: #selector(togglePopover(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc func openSettings() {
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings"
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func requestAccessibilityPermissions() {
        // First check without showing prompt
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            print("✅ Accessibility permissions already granted")
            return
        }
        
        print("⚠️ Accessibility permissions not granted, requesting...")
        
        // Show system prompt
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        AXIsProcessTrustedWithOptions(options)
        
        // Show our custom alert after system prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check again if permissions were granted
            if !AXIsProcessTrusted() {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permissions Required"
                alert.informativeText = """
                SimpleEpochConverter needs Accessibility permissions to:
                • Copy selected text when you press the hotkey
                • Read from the system clipboard
                
                Please grant permissions in:
                System Settings → Privacy & Security → Accessibility
                
                After granting permissions, the app will work immediately.
                """
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Later")
                
                NSApp.activate(ignoringOtherApps: true)
                let response = alert.runModal()
                
                if response == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
        }
    }
}
