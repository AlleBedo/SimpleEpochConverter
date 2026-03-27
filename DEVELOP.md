# Development Guide

This guide provides detailed information for developers who want to build, modify, or contribute to SimpleEpochConverter.

## 📋 Prerequisites

- **macOS 13.0 (Ventura)** or later
- **Xcode Command Line Tools** (not full Xcode required)
- **Swift 5.0+**

Install Command Line Tools:
```bash
xcode-select --install
```

## 🏗️ Project Structure

```
SimpleEpochConverter/
├── Sources/                   # Swift source files
│   ├── SimpleEpochConverterApp.swift
│   ├── ContentView.swift
│   ├── SettingsView.swift
│   ├── HotKeyManager.swift
│   └── EpochConverter.swift
│
├── Resources/                 # App resources
│   ├── icon.png              # Source icon (1024x1024 PNG)
│   ├── AppIcon.icns          # App icon bundle
│   └── spiral.svg            # Menu bar icon
│
├── Scripts/                   # Build and distribution scripts
│   ├── manage.sh             # Main build/run script
│   ├── create_icon.sh        # Icon generation script
│   └── homebrew-cask.rb      # Homebrew distribution formula
│
├── build/                     # Build artifacts (gitignored)
│   ├── SimpleEpochConverter.app
│   └── SimpleEpochConverter-*.zip
│
├── SimpleEpochConverter.xcodeproj/  # Xcode project
├── Info.plist                # App configuration
├── SimpleEpochConverter.entitlements
└── README.md
```

## 🔧 Building the App

### Option 1: Using manage.sh (Recommended)

```bash
# Build and run immediately
./Scripts/manage.sh start

# Just build
./Scripts/manage.sh build

# Run without rebuilding
./Scripts/manage.sh run

# Clean build directory
./Scripts/manage.sh clean

# Clean and rebuild
./Scripts/manage.sh rebuild

# Create distribution package
./Scripts/manage.sh package

# Verify build health
./Scripts/manage.sh verify

# Stop running app
./Scripts/manage.sh stop

# Show help
./Scripts/manage.sh help
```

### Option 2: Using Xcode

1. Open the project:
   ```bash
   open SimpleEpochConverter.xcodeproj
   ```

2. Select your development team in project settings

3. Build and run with <kbd>⌘</kbd> + <kbd>R</kbd>

## 📁 Source Code Organization

### `Sources/`

- **SimpleEpochConverterApp.swift**: App entry point and menu bar setup
  - Creates status bar item with custom icon
  - Manages popover window
  - Handles right-click context menu
  - Initializes hot key manager

- **ContentView.swift**: Main popover UI
  - Displays conversion results
  - Shows epoch, date, and relative time
  - Provides copy buttons
  - Uses custom spiral icon

- **SettingsView.swift**: Settings window
  - Interactive shortcut recorder
  - Launch at login toggle
  - Uses `NSViewRepresentable` for native hotkey capture

- **HotKeyManager.swift**: Global hotkey management
  - Carbon framework integration
  - Text selection capture via clipboard
  - Accessibility permissions handling

- **EpochConverter.swift**: Conversion logic
  - Handles seconds and milliseconds
  - English date formatting
  - Relative time calculation

### `Resources/`

- **icon.png**: Source PNG icon (1024x1024px recommended)
- **AppIcon.icns**: Generated multi-resolution bundle for app icon
- **spiral.svg**: SVG icon used in menu bar and popover

To regenerate app icon:
```bash
./Scripts/create_icon.sh
```

### `Scripts/`

- **manage.sh**: All-in-one build automation
  - Compiles Swift files with `swiftc`
  - Copies resources to app bundle
  - Creates Info.plist
  - Packages for distribution

- **create_icon.sh**: Icon generation
  - Converts icon.png to all required sizes
  - Creates .icns bundle with `iconutil`

- **homebrew-cask.rb**: Homebrew formula template
  - Update version and SHA256 for releases
  - Copy to your homebrew-tap repository

## 🔨 Build Process Details

The `manage.sh` script performs these steps:

1. **Setup**: Creates build directories
2. **Icon Copy**: Copies AppIcon.icns and spiral.svg to Resources
3. **Compilation**: Compiles all Swift files using `swiftc`:
   ```bash
   swiftc -o executable \
     -framework Cocoa \
     -framework SwiftUI \
     -framework Carbon \
     -framework ServiceManagement \
     Sources/*.swift
   ```
4. **Info.plist**: Generates app metadata
5. **PkgInfo**: Creates app type identifier

## 📦 Distribution

### Creating a Release Package

```bash
./Scripts/manage.sh package
```

This creates `SimpleEpochConverter-1.0.zip` with:
- App bundle
- Quarantine attributes removed
- SHA256 hash calculated

### Homebrew Distribution

1. Create GitHub release with the `.zip` file
2. Update `Scripts/homebrew-cask.rb`:
   - Set correct version
   - Update SHA256 hash
3. Copy to your homebrew-tap repository:
   ```bash
   cp Scripts/homebrew-cask.rb /path/to/homebrew-tap/Casks/simple-epoch-converter.rb
   ```

## 🐛 Debugging

### Verbose Output

The app logs debug information to stdout:
```bash
# Run from terminal to see logs
./Scripts/manage.sh run
```

### Common Issues

**Accessibility permissions not working:**
- Check System Settings → Privacy & Security → Accessibility
- App must be restarted after granting permissions

**Icon not updating:**
- Run `./Scripts/create_icon.sh`
- Clean and rebuild: `./Scripts/manage.sh rebuild`

**Hot key conflicts:**
- Check other apps aren't using the same shortcut
- Try changing shortcut from settings

## 🧪 Testing

Manual testing checklist:
- [ ] App launches without errors
- [ ] Menu bar icon appears
- [ ] Global shortcut captures selected text
- [ ] Epoch conversion works (seconds and milliseconds)
- [ ] Relative time displays correctly
- [ ] Settings window opens and saves preferences
- [ ] Launch at login toggle works
- [ ] Custom shortcuts can be configured
- [ ] Accessibility permissions prompt appears

## 🔐 Code Signing

Currently, the app is **not code signed**. To distribute without Gatekeeper warnings:

### Option 1: Sign with Apple Developer Certificate

Requires Apple Developer Program ($99/year):
```bash
codesign --deep --force --sign "Developer ID Application: Your Name" \
  build/SimpleEpochConverter.app
```

### Option 2: Notarization

After signing, submit for notarization:
```bash
xcrun notarytool submit SimpleEpochConverter-1.0.zip \
  --apple-id your@email.com \
  --team-id TEAMID \
  --password app-specific-password
```

### Option 3: Remove Quarantine (Current Method)

The homebrew cask automatically runs:
```bash
xattr -cr /Applications/SimpleEpochConverter.app
```

## 🤝 Contributing

### Code Style

- Use Swift naming conventions
- Add comments for complex logic
- Keep functions focused and small
- Use SwiftUI where possible

### Pull Request Process

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Test thoroughly on your machine
4. Commit with clear messages
5. Push and create Pull Request

### Areas for Contribution

- [ ] Unit tests
- [ ] Automated UI tests
- [ ] Additional timestamp formats
- [ ] Localization (other languages)
- [ ] Dark mode improvements
- [ ] Performance optimizations

## 📚 Dependencies

The app uses only macOS system frameworks:
- **Cocoa**: AppKit integration
- **SwiftUI**: Modern UI
- **Carbon**: Global hotkey registration
- **ServiceManagement**: Launch at login

No external dependencies required!

## 🔍 Architecture Notes

- **Menu Bar App**: Uses `NSStatusItem` with `.accessory` policy (no dock icon)
- **Popover UI**: SwiftUI views hosted in `NSPopover`
- **Global Hotkeys**: Carbon Event Manager for system-wide shortcuts
- **Settings Persistence**: `@AppStorage` backed by UserDefaults
- **Launch at Login**: macOS 13+ `SMAppService` API

## 📝 Version Management

Update version in:
1. `Info.plist` → `CFBundleShortVersionString`
2. `Scripts/homebrew-cask.rb` → `version`

## 🚀 Release Checklist

- [ ] Update version in Info.plist
- [ ] Test build with `./Scripts/manage.sh rebuild`
- [ ] Create package with `./Scripts/manage.sh package`
- [ ] Create GitHub release with tag `v1.x.x`
- [ ] Upload .zip to GitHub release
- [ ] Update homebrew-cask.rb with new SHA256
- [ ] Update CHANGELOG.md
- [ ] Test homebrew installation

---

For user documentation, see [README.md](README.md).
