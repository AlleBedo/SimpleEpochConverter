import SwiftUI

enum ConversionMode: String, CaseIterable {
    case epochToDate = "Epoch → Date"
    case dateToEpoch = "Date → Epoch"
}

struct ContentView: View {
    @ObservedObject private var converter = EpochConverter.shared
    @ObservedObject private var settings = AppSettings.shared
    @State private var mode: ConversionMode = .epochToDate
    @State private var manualInput: String = ""
    @State private var selectedDate = Date()
    @State private var copiedField: String?
    @State private var currentEpoch: Int64 = Int64(Date().timeIntervalSince1970)
    @State private var keyMonitor: Any?

    private let epochTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Load custom icon
    private var customIcon: Image? {
        if let resourcePath = Bundle.main.resourcePath,
           let nsImage = NSImage(contentsOfFile: resourcePath + "/spiral.svg") {
            nsImage.size = NSSize(width: 24, height: 24)
            return Image(nsImage: nsImage)
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Group {
                    if let icon = customIcon {
                        icon
                    } else {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                .font(.title2)
                .foregroundColor(.accentColor)

                Text("Epoch Converter")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }

            // Mode picker
            Picker("", selection: $mode) {
                ForEach(ConversionMode.allCases, id: \.self) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)

            // Input area
            if mode == .epochToDate {
                epochToDateView
            } else {
                dateToEpochView
            }

            Spacer(minLength: 0)

            // Current epoch footer
            HStack {
                Text("Now:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(currentEpoch)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)

                Spacer()

                copyButton(value: "\(currentEpoch)", field: "now") {
                    Image(systemName: copiedField == "now" ? "checkmark" : "doc.on.doc")
                        .font(.caption2)
                        .foregroundColor(copiedField == "now" ? .green : .secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(width: 380, height: settings.showUTC ? 440 : 380)
        .onReceive(epochTimer) { _ in
            currentEpoch = Int64(Date().timeIntervalSince1970)
        }
        .onAppear {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard event.modifierFlags.contains(.command) else { return event }
                switch event.charactersIgnoringModifiers {
                case "1":
                    handleCopyShortcut(index: 1)
                    return nil
                case "2":
                    handleCopyShortcut(index: 2)
                    return nil
                default:
                    return event
                }
            }
        }
        .onDisappear {
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
                keyMonitor = nil
            }
        }
    }

    private func handleCopyShortcut(index: Int) {
        if mode == .epochToDate {
            guard let result = converter.lastConversion else { return }
            switch index {
            case 1:
                copyToClipboard(result.epoch, field: "epoch")
            case 2:
                copyToClipboard(result.date, field: "date")
            default: break
            }
        } else {
            guard let result = converter.lastReverseConversion else { return }
            switch index {
            case 1:
                copyToClipboard(result.epochSeconds, field: "epochSec")
            case 2:
                copyToClipboard(result.epochMilliseconds, field: "epochMs")
            default: break
            }
        }
    }

    private func copyToClipboard(_ value: String, field: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        withAnimation { copiedField = field }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                if copiedField == field { copiedField = nil }
            }
        }
    }

    // MARK: - Epoch to Date

    private var epochToDateView: some View {
        VStack(spacing: 12) {
            // Manual input field
            HStack(spacing: 8) {
                TextField("Enter epoch timestamp...", text: $manualInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit { convertManualInput() }

                Button("Convert") { convertManualInput() }
                    .buttonStyle(.borderedProminent)
                    .disabled(manualInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if let result = converter.lastConversion {
                VStack(spacing: 10) {
                    // Epoch display
                    resultCard(
                        label: "TIMESTAMP EPOCH",
                        background: Color.accentColor.opacity(0.1)
                    ) {
                        HStack {
                            Text(result.epoch)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)
                            Spacer()
                            copyButton(value: result.epoch, field: "epoch") {
                                Image(systemName: copiedField == "epoch" ? "checkmark" : "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(copiedField == "epoch" ? .green : .secondary)
                            }
                        }
                    }

                    // Date display
                    resultCard(
                        label: "DATE & TIME (LOCAL)",
                        background: Color.secondary.opacity(0.08)
                    ) {
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
                            copyButton(value: result.date, field: "date") {
                                Image(systemName: copiedField == "date" ? "checkmark" : "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(copiedField == "date" ? .green : .secondary)
                            }
                        }
                    }

                    if let utcDate = result.utcDate {
                        resultCard(
                            label: "DATE & TIME (UTC)",
                            background: Color.secondary.opacity(0.08)
                        ) {
                            HStack {
                                Text(utcDate)
                                    .font(.body)
                                    .textSelection(.enabled)
                                Spacer()
                                copyButton(value: utcDate, field: "utcDate") {
                                    Image(systemName: copiedField == "utcDate" ? "checkmark" : "doc.on.doc")
                                        .font(.caption)
                                        .foregroundColor(copiedField == "utcDate" ? .green : .secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Group {
                        if let icon = customIcon {
                            icon.font(.system(size: 28))
                        } else {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 28))
                        }
                    }
                    .foregroundColor(.secondary.opacity(0.6))

                    VStack(spacing: 4) {
                        Text("Enter an epoch above or select text and press")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(settings.shortcutDisplayString)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Date to Epoch

    private var dateToEpochView: some View {
        VStack(spacing: 12) {
            DatePicker("Select date:", selection: $selectedDate)
                .datePickerStyle(.field)
                .labelsHidden()

            Button("Convert to Epoch") {
                converter.convertDateToEpoch(selectedDate)
            }
            .buttonStyle(.borderedProminent)

            if let result = converter.lastReverseConversion {
                VStack(spacing: 10) {
                    resultCard(
                        label: "DATE (LOCAL)",
                        background: Color.accentColor.opacity(0.1)
                    ) {
                        Text(result.date)
                            .font(.body)
                            .textSelection(.enabled)
                    }

                    if let utcDate = result.utcDate {
                        resultCard(
                            label: "DATE (UTC)",
                            background: Color.accentColor.opacity(0.1)
                        ) {
                            Text(utcDate)
                                .font(.body)
                                .textSelection(.enabled)
                        }
                    }

                    resultCard(
                        label: "EPOCH (SECONDS)",
                        background: Color.secondary.opacity(0.08)
                    ) {
                        HStack {
                            Text(result.epochSeconds)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)
                            Spacer()
                            copyButton(value: result.epochSeconds, field: "epochSec") {
                                Image(systemName: copiedField == "epochSec" ? "checkmark" : "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(copiedField == "epochSec" ? .green : .secondary)
                            }
                        }
                    }

                    resultCard(
                        label: "EPOCH (MILLISECONDS)",
                        background: Color.secondary.opacity(0.08)
                    ) {
                        HStack {
                            Text(result.epochMilliseconds)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)
                            Spacer()
                            copyButton(value: result.epochMilliseconds, field: "epochMs") {
                                Image(systemName: copiedField == "epochMs" ? "checkmark" : "doc.on.doc")
                                    .font(.caption)
                                    .foregroundColor(copiedField == "epochMs" ? .green : .secondary)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("Pick a date and convert to epoch")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Helpers

    private func resultCard<Content: View>(
        label: String,
        background: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .cornerRadius(8)
    }

    private func copyButton<Label: View>(
        value: String,
        field: String,
        @ViewBuilder label: () -> Label
    ) -> some View {
        Button(action: { copyToClipboard(value, field: field) }) {
            label()
        }
        .buttonStyle(.plain)
        .help("Copy")
    }

    private func convertManualInput() {
        let text = manualInput.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        converter.convertEpoch(text)
        manualInput = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
