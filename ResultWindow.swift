import SwiftUI
import Cocoa

class ResultWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 250),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Epoch Converter - Risultato"
        self.center()
        self.isReleasedWhenClosed = false
        
        // Crea la vista SwiftUI
        let contentView = ResultContentView()
        self.contentView = NSHostingView(rootView: contentView)
        
        // Imposta la finestra come floating per essere sempre visibile
        self.level = .floating
        
        // Configura l'aspetto
        self.backgroundColor = NSColor.windowBackgroundColor
        self.isOpaque = true
        
        // Fai apparire la finestra con una animazione
        self.alphaValue = 0
        self.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        }
    }
    
    func show() {
        self.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ResultContentView: View {
    @StateObject private var converter = EpochConverter.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title)
                    .foregroundColor(.accentColor)
                
                Text("Conversione Epoch")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            if let result = converter.lastConversion {
                VStack(spacing: 16) {
                    // Epoch originale
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Timestamp Epoch")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        HStack {
                            Text(result.epoch)
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result.epoch, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Copia epoch")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Data convertita
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Data e Ora")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        HStack {
                            Text(result.date)
                                .font(.body)
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result.date, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Copia data")
                        }
                        
                        Text(result.relativeTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Text("Nessuna conversione disponibile")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Shortcut: ⌘ ⇧ E")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Chiudi") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.escape)
            }
        }
        .padding(24)
        .frame(width: 450, height: 250)
    }
}

struct ResultContentView_Previews: PreviewProvider {
    static var previews: some View {
        ResultContentView()
    }
}
