# Project Structure

```
SimpleEpochConverter/
├── Sources/                   # Swift source files
│   ├── SimpleEpochConverterApp.swift
│   ├── ContentView.swift
│   ├── SettingsView.swift
│   ├── ResultWindow.swift
│   ├── HotKeyManager.swift
│   └── EpochConverter.swift
│
├── Resources/                 # App resources
│   ├── icon.png              # Source icon (PNG)
│   ├── AppIcon.icns          # App icon bundle
│   └── spiral.svg            # Menu bar icon
│
├── Scripts/                   # Build and distribution scripts
│   ├── manage.sh             # Main build/run script
│   ├── create_icon.sh        # Icon generation script
│
├── build/                     # Build artifacts (gitignored)
│   ├── SimpleEpochConverter.app
│   └── SimpleEpochConverter-*.zip
│
├── SimpleEpochConverter.xcodeproj/  # Xcode project
├── Info.plist                # App configuration
├── SimpleEpochConverter.entitlements
├── LICENSE
└── README.md
```

## Directory Details

### `Sources/`
Contains all Swift source code organized by functionality:
- **SimpleEpochConverterApp.swift**: App entry point and menu bar setup
- **ContentView.swift**: Main popover UI
- **SettingsView.swift**: Settings window and shortcut configuration
- **ResultWindow.swift**: Result display window
- **HotKeyManager.swift**: Global hotkey registration and management
- **EpochConverter.swift**: Timestamp conversion logic

### `Resources/`
Assets and resources bundled with the app:
- **icon.png**: Source 1024x1024 PNG icon
- **AppIcon.icns**: Generated multi-resolution icon bundle
- **spiral.svg**: SVG icon for menu bar

### `Scripts/`
Build automation and distribution:
- **manage.sh**: Complete build/run/package management
  ```bash
  ./Scripts/manage.sh build    # Build the app
  ./Scripts/manage.sh run      # Run the app
  ./Scripts/manage.sh package  # Create distribution zip
  ```
- **create_icon.sh**: Convert icon.png to AppIcon.icns
- **homebrew-cask.rb**: Homebrew distribution formula

### `build/`
Generated during compilation (not in git):
- `SimpleEpochConverter.app`: Built application bundle
- `SimpleEpochConverter-*.zip`: Distribution packages

## Quick Start

```bash
# Build and run
./Scripts/manage.sh start

# Or just build
./Scripts/manage.sh build

# Create distribution package
./Scripts/manage.sh package
```
