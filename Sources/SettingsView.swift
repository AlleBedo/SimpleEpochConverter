import SwiftUI
import ServiceManagement
import Carbon

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onShortcutRecorded: (UInt32, UInt32) -> Void
    
    func makeNSView(context: Context) -> ShortcutCaptureView {
        let view = ShortcutCaptureView()
        view.onShortcutCaptured = { modifiers, keyCode in
            onShortcutRecorded(modifiers, keyCode)
            isRecording = false
        }
        return view
    }
    
    func updateNSView(_ nsView: ShortcutCaptureView, context: Context) {
        if isRecording {
            nsView.startRecording()
        } else {
            nsView.stopRecording()
        }
    }
}

class ShortcutCaptureView: NSView {
    var onShortcutCaptured: ((UInt32, UInt32) -> Void)?
    private var localMonitor: Any?
    
    override var acceptsFirstResponder: Bool { true }
    
    func startRecording() {
        window?.makeFirstResponder(self)
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            let modifiers = event.modifierFlags.carbonModifiers()
            let keyCode = UInt32(event.keyCode)
            
            // Require at least one modifier key
            if modifiers != 0 {
                self.onShortcutCaptured?(modifiers, keyCode)
                return nil // Consume the event
            }
            
            return event
        }
    }
    
    func stopRecording() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
    
    deinit {
        stopRecording()
    }
}

extension NSEvent.ModifierFlags {
    func carbonModifiers() -> UInt32 {
        var modifiers: UInt32 = 0
        
        if contains(.control) {
            modifiers |= UInt32(controlKey)
        }
        if contains(.option) {
            modifiers |= UInt32(optionKey)
        }
        if contains(.shift) {
            modifiers |= UInt32(shiftKey)
        }
        if contains(.command) {
            modifiers |= UInt32(cmdKey)
        }
        
        return modifiers
    }
}

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.dismiss) var dismiss
    @State private var isRecordingShortcut = false
    
    private var previewCustomFormat: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = settings.customDateFormat
        return formatter.string(from: Date(timeIntervalSince1970: 1700000000))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Content
            Form {
                // Shortcut Section
                Section(header: Text("Global Shortcut")) {
                    HStack {
                        Text("Current shortcut:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(settings.shortcutDisplayString)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(6)
                    }
                    
                    if isRecordingShortcut {
                        VStack(spacing: 8) {
                            ShortcutRecorderView(isRecording: $isRecordingShortcut) { modifiers, keyCode in
                                settings.saveShortcut(modifiers: modifiers, key: keyCode)
                            }
                            .frame(height: 40)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                            
                            Text("Press your desired key combination...")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Button("Cancel") {
                                isRecordingShortcut = false
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button("Change Shortcut") {
                            isRecordingShortcut = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Reset to Default (⌘ + ⇧ + E)") {
                        settings.resetShortcut()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRecordingShortcut)
                }
                
                // Display Section
                Section(header: Text("Display")) {
                    Picker("Date format:", selection: Binding(
                        get: { settings.dateFormatOption },
                        set: { settings.saveDateFormat($0) }
                    )) {
                        ForEach(DateFormatOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }

                    Text(settings.dateFormatOption == .custom
                         ? "Preview: \(previewCustomFormat)"
                         : "Example: \(settings.dateFormatOption.example)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if settings.dateFormatOption == .custom {
                        TextField("Format pattern", text: Binding(
                            get: { settings.customDateFormat },
                            set: { settings.saveCustomDateFormat($0) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                        Text("Uses Unicode date format patterns (e.g. yyyy-MM-dd HH:mm:ss)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Toggle("Show UTC time", isOn: Binding(
                        get: { settings.showUTC },
                        set: { settings.saveShowUTC($0) }
                    ))

                    Text("Display UTC alongside your local timezone in conversion results.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Startup Section
                Section(header: Text("Launch")) {
                    Toggle("Launch at login", isOn: $settings.launchAtLogin)
                        .onChange(of: settings.launchAtLogin) { newValue in
                            settings.toggleLaunchAtLogin(newValue)
                        }
                    
                    Text("When enabled, the app will start automatically when you log in to your Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Simple Epoch Converter")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 450, height: 580)
    }
}

enum DateFormatOption: String, CaseIterable, Identifiable {
    case defaultFormat = "MMMM d, yyyy 'at' HH:mm:ss z"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    case rfc2822 = "EEE, dd MMM yyyy HH:mm:ss Z"
    case short = "yyyy-MM-dd HH:mm:ss"
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .defaultFormat: return "Default"
        case .iso8601: return "ISO 8601"
        case .rfc2822: return "RFC 2822"
        case .short: return "Short"
        case .custom: return "Custom"
        }
    }

    var example: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        let sampleDate = Date(timeIntervalSince1970: 1700000000)
        switch self {
        case .custom:
            return "User-defined pattern"
        default:
            formatter.dateFormat = rawValue
            return formatter.string(from: sampleDate)
        }
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // Shortcut settings
    @Published var modifierFlags: UInt32
    @Published var keyCode: UInt32
    @Published var launchAtLogin: Bool

    // Display settings
    @Published var dateFormatOption: DateFormatOption
    @Published var customDateFormat: String
    @Published var showUTC: Bool

    private let defaults = UserDefaults.standard

    private init() {
        // Load saved settings or use defaults
        let savedModifiers = UInt32(defaults.integer(forKey: "shortcutModifiers"))
        self.modifierFlags = savedModifiers == 0 ? UInt32(cmdKey | shiftKey) : savedModifiers

        let savedKeyCode = UInt32(defaults.integer(forKey: "shortcutKeyCode"))
        self.keyCode = savedKeyCode == 0 ? 14 : savedKeyCode

        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")

        // Display settings
        if let savedFormat = defaults.string(forKey: "dateFormatOption"),
           let option = DateFormatOption(rawValue: savedFormat) {
            self.dateFormatOption = option
        } else {
            self.dateFormatOption = .defaultFormat
        }
        self.customDateFormat = defaults.string(forKey: "customDateFormat") ?? "yyyy/MM/dd HH:mm:ss"
        self.showUTC = defaults.bool(forKey: "showUTC")
    }

    var activeDateFormat: String {
        if dateFormatOption == .custom {
            return customDateFormat
        }
        return dateFormatOption.rawValue
    }

    func saveDateFormat(_ option: DateFormatOption) {
        self.dateFormatOption = option
        defaults.set(option.rawValue, forKey: "dateFormatOption")
    }

    func saveCustomDateFormat(_ format: String) {
        self.customDateFormat = format
        defaults.set(format, forKey: "customDateFormat")
    }

    func saveShowUTC(_ enabled: Bool) {
        self.showUTC = enabled
        defaults.set(enabled, forKey: "showUTC")
    }
    
    var shortcutDisplayString: String {
        var parts: [String] = []
        
        // Check modifiers
        if modifierFlags & UInt32(controlKey) != 0 {
            parts.append("⌃")
        }
        if modifierFlags & UInt32(optionKey) != 0 {
            parts.append("⌥")
        }
        if modifierFlags & UInt32(shiftKey) != 0 {
            parts.append("⇧")
        }
        if modifierFlags & UInt32(cmdKey) != 0 {
            parts.append("⌘")
        }
        
        // Add key name
        parts.append(keyCodeToString(keyCode))
        
        return parts.joined(separator: " + ")
    }
    
    private func keyCodeToString(_ code: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            // Letters
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P",
            37: "L", 38: "J", 40: "K", 45: "N", 46: "M",
            // Numbers
            18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5",
            25: "9", 26: "7", 28: "8", 29: "0",
            // Special keys
            36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
            // Arrow keys
            123: "←", 124: "→", 125: "↓", 126: "↑",
            // Function keys
            96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8",
            101: "F9", 109: "F10", 103: "F11", 111: "F12",
            118: "F4", 120: "F2", 122: "F1",
            // Punctuation
            24: "=", 27: "-", 30: "]", 33: "[", 39: "'",
            41: ";", 42: "\\", 43: ",", 44: "/", 47: ".",
            50: "`",
        ]
        return keyMap[code] ?? "Key\(code)"
    }
    
    func saveShortcut(modifiers: UInt32, key: UInt32) {
        self.modifierFlags = modifiers
        self.keyCode = key
        
        defaults.set(Int(modifiers), forKey: "shortcutModifiers")
        defaults.set(Int(key), forKey: "shortcutKeyCode")
        
        // Notify to re-register hotkey
        NotificationCenter.default.post(name: NSNotification.Name("ShortcutChanged"), object: nil)
    }
    
    func resetShortcut() {
        saveShortcut(modifiers: UInt32(cmdKey | shiftKey), key: 14)
    }
    
    func toggleLaunchAtLogin(_ enabled: Bool) {
        defaults.set(enabled, forKey: "launchAtLogin")
        
        if #available(macOS 13.0, *) {
            if enabled {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }
}
