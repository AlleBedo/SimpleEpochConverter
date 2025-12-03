import SwiftUI

struct ContentView: View {
    @StateObject private var converter = EpochConverter.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Epoch Converter")
                .font(.title2)
                .fontWeight(.bold)
            
            if let result = converter.lastConversion {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Epoch:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(result.epoch)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                    
                    Divider()
                    
                    Text("Data:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(result.date)
                        .font(.body)
                        .textSelection(.enabled)
                    
                    Text(result.relativeTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Seleziona un timestamp epoch e premi")
                        .font(.body)
                    Text("⌘ + ⇧ + E")
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            Text("Shortcut: ⌘ + ⇧ + E")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
