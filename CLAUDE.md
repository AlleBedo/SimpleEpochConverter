# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SimpleEpochConverter is a macOS menu bar app (Swift/SwiftUI) that converts Unix epoch timestamps to human-readable dates via a global hotkey. It runs as a status bar item with no dock icon. Requires macOS 13.0+.

## Build Commands

All builds go through `./Scripts/manage.sh`:

```bash
./Scripts/manage.sh build     # Compile only
./Scripts/manage.sh start     # Build and run
./Scripts/manage.sh run       # Run without rebuilding
./Scripts/manage.sh debug     # Run with console output
./Scripts/manage.sh rebuild   # Clean + build
./Scripts/manage.sh stop      # Kill running process
./Scripts/manage.sh verify    # Check build integrity
./Scripts/manage.sh clean     # Remove build artifacts
./Scripts/manage.sh package   # Create .zip distribution
```

The build uses `swiftc` directly (no SPM, no CocoaPods) linking Cocoa, SwiftUI, Carbon, and ServiceManagement frameworks. Output goes to `build/SimpleEpochConverter.app`. Can also build via Xcode: `open SimpleEpochConverter.xcodeproj`.

There are no automated tests. Testing is manual only.

## Architecture

- **Entry point**: `Sources/SimpleEpochConverterApp.swift` — `AppDelegate` creates the `NSStatusItem`, manages an `NSPopover` for the UI, and registers the global hotkey
- **Global hotkeys**: `Sources/HotKeyManager.swift` — Uses Carbon Event Manager (`RegisterEventHotKey`). Captures selected text by simulating Cmd+C and reading the clipboard. Requires Accessibility permissions (`AXIsProcessTrusted`)
- **Conversion logic**: `Sources/EpochConverter.swift` — Singleton. Auto-detects seconds vs milliseconds (threshold: 9,999,999,999). Produces formatted date + relative time string
- **Main UI**: `Sources/ContentView.swift` — SwiftUI popover (380x280) showing conversion results with copy buttons
- **Settings**: `Sources/SettingsView.swift` — Contains both the SwiftUI view and `AppSettings` class (UserDefaults-backed). Shortcut customization uses `NSViewRepresentable` for native key capture. Launch-at-login uses `SMAppService`

## Key Technical Details

- Zero external dependencies — pure Apple system frameworks
- Bundle ID: `com.alessandrobedini.SimpleEpochConverter`
- App is unsigned; distribution removes quarantine via `xattr -cr`
- Version is tracked in `Info.plist` (`CFBundleShortVersionString`) and `Scripts/homebrew-cask.rb`
- Distributed via Homebrew tap `allebedo/tap` and GitHub Releases
