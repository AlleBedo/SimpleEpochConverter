<div align="center">
  <img width="96px" src="icon.png" alt="Logo" />
  <h1>Simple Epoch Converter</h1>
</div>

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![macOS](https://img.shields.io/badge/macOS-13.0+-green.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A simple and fast macOS menu bar application to convert epoch timestamps to human-readable dates.

## ✨ Features

- **Instant Conversion**: Select an epoch timestamp anywhere on your Mac and press the global shortcut
- **Global Shortcut**: <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>E</kbd> (Command + Shift + E) works system-wide
- **Multiple Formats**: Handles both seconds and milliseconds timestamps
- **Relative Time**: Shows how long ago or until the date ("3 days ago", "in 2 hours")
- **Menu Bar Icon**: Discreet clock icon in the menu bar for quick access
- **SwiftUI Interface**: Modern, native macOS interface with floating result window
- **Easy Copy**: Copy both epoch and converted date with a single click

## 🚀 Usage

### First Time Setup

1. Grant accessibility permissions when prompted:
   - Go to **System Preferences** → **Privacy & Security** → **Accessibility**
   - Add **SimpleEpochConverter** to the authorized apps list
   - Restart the app after granting permissions

### Converting Timestamps

1. **Select** an epoch timestamp in any app (browser, terminal, text editor, etc.)
2. **Press** <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>E</kbd>
3. **View** the converted date in the result window

Alternatively, click the menu bar icon to view the last conversion.

### Examples

- **Seconds**: `1733184000` → December 3, 2024
- **Milliseconds**: `1733184000000` → December 3, 2024
- **In text**: "timestamp: 1733184000" → Automatically extracts the number

## 🛠️ Installation

### Option A: Install with Homebrew (Easiest)

```bash
# Add the tap
brew tap allebedo/tap

# Install the app
brew install --cask simple-epoch-converter
```

The app will be automatically installed to `/Applications` and the quarantine attributes will be removed.

**First launch**: You'll need to grant Accessibility permissions in System Settings → Privacy & Security → Accessibility.

### Option B: Build with Xcode

1. Open the project:
   ```bash
   open SimpleEpochConverter.xcodeproj
   ```

2. Select your development team in the project settings

3. Build and run (`⌘ + R`)

### Option C: Build from Terminal (No Xcode Required)

You can compile and run the app using only the Swift compiler:

```bash
# Quick start - builds and runs the app
./Scripts/manage.sh start
```

See the [Building Without Xcode](#building-without-xcode) section for details.

## 🔧 Building Without Xcode

### Prerequisites

- macOS 13.0 or later
- Xcode Command Line Tools (not full Xcode)

Install Command Line Tools:
```bash
xcode-select --install
```

### Build Commands

The `manage.sh` script provides all necessary build commands:

```bash
# Build the app
./Scripts/manage.sh build

# Run the app
./Scripts/manage.sh run

# Build and run
./Scripts/manage.sh start

# Verify build integrity
./Scripts/manage.sh verify

# Clean build artifacts
./Scripts/manage.sh clean

# Rebuild from scratch
./Scripts/manage.sh rebuild

# Show all commands
./Scripts/manage.sh help
```

### How It Works

The build script:

1. Automatically detects your CPU architecture (Intel/Apple Silicon)
2. Compiles Swift files using `swiftc`
3. Creates a proper `.app` bundle structure
4. Generates `Info.plist` with correct values
5. Sets up all necessary permissions

The resulting app is functionally identical to one built with Xcode!

### Build Output

After building, the app is located at:
```
build/SimpleEpochConverter.app
```

## 📋 Available Commands

The `manage.sh` script provides a unified interface for all operations:

| Command | Description |
|---------|-------------|
| `build` | Compile the application |
| `run` | Launch the application |
| `start` | Build and run in one command |
| `stop` | Terminate the application |
| `restart` | Stop and restart the application |
| `rebuild` | Clean and rebuild from scratch |
| `verify` | Verify build integrity and configuration |
| `clean` | Remove build artifacts |
| `status` | Check if app is running |
| `help` | Show all available commands |

## 🔐 Permissions

The app requires the following permissions:

- **Accessibility**: To read selected text when using the global shortcut
- **Apple Events**: To simulate `Cmd+C` for copying selected text

These permissions are only needed for the global shortcut functionality. The app will request them automatically on first launch.

### Security Note

Without code signing, macOS may show a security warning on first launch:

1. Go to **System Preferences** → **Privacy & Security**
2. Click **"Open Anyway"** next to the SimpleEpochConverter message
3. Confirm by clicking **"Open"**

## 🎨 Customization

### Change the Shortcut

Edit `HotKeyManager.swift`:

```swift
// Example: Change to Cmd+Shift+T instead of Cmd+Shift+E
let modifiers = UInt32(cmdKey | shiftKey)
let keyCode: UInt32 = 17  // 't' key (14 is 'e')
```

### Change Date Format

Edit `EpochConverter.swift`:

```swift
dateFormatter.dateStyle = .long   // .short, .medium, .full
dateFormatter.timeStyle = .long   // .short, .medium, .full
dateFormatter.locale = Locale(identifier: "en_US")  // Change locale
```

## 🐛 Troubleshooting

### The shortcut doesn't work

1. Check that you've granted Accessibility permissions
2. Restart the app after granting permissions
3. Ensure the text is selected before pressing the shortcut
4. Verify no other app is using <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>E</kbd>

### Build fails with "command not found: swiftc"

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### "The application cannot be opened"

This usually means there's an issue with the app bundle. Try:
```bash
./Scripts/manage.sh rebuild
./Scripts/manage.sh verify
```

If the issue persists, check that `Info.plist` has the correct executable name:
```bash
cat build/SimpleEpochConverter.app/Contents/Info.plist | grep CFBundleExecutable
```

### App crashes or doesn't appear in menu bar

Run with logs to see errors:
```bash
./Scripts/manage.sh stop
build/SimpleEpochConverter.app/Contents/MacOS/SimpleEpochConverter
```

### Permission denied errors

Remove quarantine attribute:
```bash
xattr -cr build/SimpleEpochConverter.app
```

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with SwiftUI for modern macOS UI
- Uses Carbon framework for global shortcuts
- Inspired by the need for quick epoch conversions during development

## 💡 Tips

- **Quick access**: Keep the app running in the background and use the shortcut anytime
- **Batch conversion**: The app remembers your last conversion, accessible via the menu bar
- **Development workflow**: Perfect for debugging timestamp issues in logs and databases
- **Time zones**: All conversions respect your system's timezone settings

---

**Made with ❤️ for developers who work with timestamps**

For support or questions, please open an issue on GitHub.
