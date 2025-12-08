import SwiftUI

struct ContentView: View {
    @StateObject private var converter = EpochConverter.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text("Epoch Converter")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let result = converter.lastConversion {
                VStack(spacing: 12) {
                    // Epoch originale
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIMESTAMP EPOCH")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text(result.epoch)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result.epoch, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Copy epoch")
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Converted date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATE & TIME")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.date)
                                    .font(.body)
                                    .textSelection(.enabled)
                                
                                Text(result.relativeTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result.date, forType: .string)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Copy date")
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(8)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 4) {
                        Text("Select a timestamp and press")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("⌘ + ⇧ + E")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.vertical, 20)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(width: 380, height: 280)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
