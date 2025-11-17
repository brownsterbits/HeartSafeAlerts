# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
HeartSafeAlerts is an iOS app that monitors heart rate via Bluetooth LE heart rate monitors (or Apple Watch via HealthKit) and provides real-time alerts when heart rate goes outside configured thresholds.

**Strategic Positioning:**
- Supports specialty Bluetooth devices that Apple doesn't (medical-grade sensors, athletic equipment)
- Adds "Care Circle" - human connection layer for loved ones/caregivers (future premium feature)
- Works alongside Apple Watch, not competing with it
- Free tier includes ALL basic monitoring; premium tier will be Care Circle subscription

## Tech Stack
- **Language**: Swift 6.0+
- **UI**: SwiftUI (iOS 18.4+)
- **Frameworks**: CoreBluetooth, StoreKit, UserNotifications, AVFoundation
- **Backend**: Firebase (configured but not currently in code)
- **Build System**: Xcode project (not workspace)

## Architecture

### Core Components

**HeartRateMonitor** (`HeartRateMonitor.swift`)
- Central `ObservableObject` managing Bluetooth connection lifecycle
- Implements `CBCentralManagerDelegate` and `CBPeripheralDelegate`
- Handles heart rate data parsing from BLE Heart Rate Service (UUID 180D)
- Manages alert logic with configurable thresholds and cooldown periods
- Features:
  - Automatic reconnection on disconnect
  - Stale data detection (>5 seconds without update)
  - Grace period (5 seconds after connection) before triggering alerts
  - Background/foreground lifecycle management
  - State restoration for background connections

**BluetoothState** (`BluetoothState.swift`)
- Enum representing all connection states with associated values
- Wraps CoreBluetooth states with app-specific states (scanning, connecting, connected, disconnected)

**PremiumManager** (`PremiumManager.swift`)
- Handles StoreKit 2 purchase flow and transaction verification
- Listens for transaction updates via `Transaction.updates`
- Stores premium state in UserDefaults ("isPremium" key)
- Product ID: `{bundleIdentifier}.pro`

**ContentView** (`ContentView.swift`)
- Main UI showing real-time heart rate with animated heart icon
- Status banner with color coding (gray/blue/orange/red/green)
- Tap-to-reconnect functionality when disconnected
- Accessibility support (VoiceOver, reduce motion)

**SettingsView** (`SettingsView.swift`)
- Heart rate threshold configuration (sliders)
- Alert settings (premium-gated with overlay)
- Device status display
- Premium status and restore purchase option

### Current Feature Set (v1.0 - Being Refactored)
**All features are becoming FREE in v1.1:**
- Real-time heart rate monitoring
- Bluetooth LE device support
- Custom threshold configuration
- Sound alerts (system sound ID 1304)
- Vibration alerts (haptic feedback)
- Background notifications
- Dark mode support

**Future Premium Feature (v1.2+):**
- **Care Circle** ($2.99/month or $19.99/year):
  - Invite up to 5 trusted contacts
  - Automatic alert escalation to circle members
  - Check-in workflow ("I'm okay" / "Need help")
  - Weekly health summaries for circle
  - Historical data and trends
  - Export reports for doctors

### Data Flow
1. User taps "Connect" → `HeartRateMonitor.startMonitoring()`
2. CoreBluetooth scans for Heart Rate Service (180D)
3. Auto-connect to first discovered device
4. Subscribe to Heart Rate Measurement characteristic (2A37)
5. Parse BLE data format (handles 8-bit and 16-bit heart rate values)
6. Update UI via `@Published` properties
7. Check thresholds → trigger alerts if premium user

### State Management
- `@StateObject` for view-owned objects (HeartRateMonitor, PremiumManager in App)
- `@EnvironmentObject` for passing down the view hierarchy
- `@Published` properties in ObservableObject classes
- `@AppStorage` for direct UserDefaults binding
- UserDefaults for persistence (thresholds, preferences, premium status)

## Build and Test Commands

### Build for Simulator
```bash
# Using XcodeBuild MCP (preferred)
mcp__xcodebuild__build_sim --projectPath HeartSafeAlerts.xcodeproj --scheme HeartSafeAlerts --simulatorName "iPhone 16"

# Using xcodebuild directly
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
```

### Run Tests
```bash
# All tests via XcodeBuild MCP
mcp__xcodebuild__test_sim --projectPath HeartSafeAlerts.xcodeproj --scheme HeartSafeAlerts --simulatorName "iPhone 16"

# Specific test class
xcodebuild test -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -only-testing:HeartSafeAlertsTests/ClassName

# UI tests only
xcodebuild test -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -only-testing:HeartSafeAlertsUITests
```

### Clean Build
```bash
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts clean
```

### Build for Device
```bash
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -configuration Release -destination 'generic/platform=iOS' build
```

## Testing In-App Purchases

1. Use `Configuration.storekit` for local testing (no sandbox account needed)
2. In Xcode: Editor → Default StoreKit Configuration → Configuration.storekit
3. Product ID must match: `com.brownster.HeartSafeAlerts.pro`
4. Test purchase flow, restore purchases, and premium feature unlocking

## Bluetooth Development Notes

### Testing Requirements
- **Must use physical device** - Bluetooth doesn't work in Simulator
- Requires compatible BLE heart rate monitor (chest strap or watch)
- Test connection/disconnection/reconnection flows
- Verify data accuracy against known heart rate

### Common Issues
- iOS 18.0 has Bluetooth stability issues (use 18.2+)
- Background connections require state restoration (implemented)
- Audio session must be configured for sound alerts to work in background
- Stale data detection prevents false alerts during signal loss

### Background Behavior
- App uses CoreBluetooth state restoration (`CBCentralManagerOptionRestoreIdentifierKey`)
- Timer-based stale checking pauses when backgrounded (battery optimization)
- Background notifications require user permission
- Sound/vibration alerts work in foreground only

## Key Constants (`Constants.swift`)
- Heart rate limits: 40-200 BPM range, default 60-100 BPM
- Alert cooldowns: 5s for local alerts, 60s for notifications
- Connection timeout: 30 seconds
- Stale data threshold: 5 seconds without update
- Grace period: 5 seconds after connection

## SwiftUI Patterns Used
- `@StateObject` for object ownership
- `@EnvironmentObject` for dependency injection
- `@AppStorage` for UserDefaults property wrapper
- `.task { }` for async initialization
- `.onChange(of:)` for reactive updates
- Conditional view rendering based on state
- Accessibility modifiers throughout

## Device Testing Priorities
1. iPhone SE (smallest screen - 4.7")
2. iPhone 16 (standard 6.1")
3. iPhone 16 Pro Max (largest 6.9")

Test both light mode (forced globally) and with system accessibility settings (VoiceOver, Reduce Motion).

## Git Workflow
- Main branch: `main`
- Feature branches: `feature/description`
- Bug fixes: `fix/issue-description`

## Important Implementation Details

### Heart Rate Data Parsing
The BLE Heart Rate Measurement format (characteristic 2A37):
- Byte 0: Flags (bit 0 = heart rate format: 0=uint8, 1=uint16)
- Byte 1(-2): Heart rate value (8-bit or 16-bit depending on flag)
- Additional bytes may contain energy expended, RR intervals (not parsed)

### Premium Status Storage
Premium status is stored in multiple places for reliability:
- `UserDefaults.standard.bool(forKey: "isPremium")`
- `PremiumManager.isPremium` (@Published)
- Purchase date: `Constants.premiumPurchaseDateKey`

All alert methods check premium status first before executing.

### Alert Cooldown Logic
- Local alerts (sound/vibration): 5 second cooldown
- Background notifications: 60 second cooldown
- Separate tracking via `lastAlertTime` and `lastNotificationTime`
- Prevents alert spam during extended threshold violations

## Current Status & Roadmap

### Active Refactoring (v1.1)
See `REFACTORING.md` for detailed plan. Key changes:
- **Removing all premium code** - Making everything free
- **Architecture cleanup** - Separating AlertManager, BluetoothManager, SessionStatistics
- **Dark mode** - Removing forced light mode
- **UI improvements** - Extracting reusable components, adding session stats

### Upcoming Features (See ROADMAP.md)
- **Phase 1 (Weeks 1-4):** HealthKit integration, session stats, App Store v1.1
- **Phase 2 (Weeks 5-12):** Care Circle MVP with subscription
- **Phase 3 (Weeks 13-20):** Apple Watch app
- **Phase 4 (Weeks 21-26):** Intelligence layer (pattern detection, personalization)

## Current Limitations
- No landscape orientation support
- No HealthKit integration yet (in Phase 1)
- No historical data storage (coming in Phase 2)
- No Firebase integration active
- Premium code being removed (in progress)
- No SwiftLint configuration

## New Architecture (Post-Refactoring)

### Separation of Concerns
The refactored architecture separates responsibilities:

**AlertManager** - Alert logic only
- Threshold checking
- Cooldown management
- Sound/vibration/notification triggering
- No Bluetooth or UI concerns

**BluetoothManager** - BLE connection only
- CoreBluetooth delegate
- Device scanning/connection
- Heart rate data parsing
- No alert logic

**SessionStatistics** - Data tracking
- Min/max/average calculations
- Time in/out of range
- Session timing
- No alerts or connection concerns

**HeartRateMonitor** - Coordination layer
- Composes managers above
- Routes data between managers
- Provides unified interface to UI

This makes testing easier, reduces coupling, and prepares for HealthKit integration.

## Info.plist Required Entries
- `NSBluetoothAlwaysUsageDescription` - "Heart rate monitoring requires Bluetooth"
- `NSHealthShareUsageDescription` - "Read heart rate from Apple Watch" (Phase 1)
- `UIBackgroundModes` - bluetooth-central
- Background capabilities enabled in project settings

## Key Files & Organization

### Core Managers (Post-Refactoring)
- `HeartRateMonitor.swift` - Main coordinator
- `AlertManager.swift` - Alert logic
- `BluetoothManager.swift` - BLE handling
- `SessionStatistics.swift` - Stats tracking

### Views
- `ContentView.swift` - Main dashboard
- `SettingsView.swift` - Configuration
- `StatusBanner.swift` - Connection status (extracted component)
- `HeartRateDisplay.swift` - BPM display (extracted component)
- `SessionStatsView.swift` - Session statistics (new)
- `CareCirclePreviewView.swift` - Future feature preview (new)

### Supporting Files
- `BluetoothState.swift` - State machine
- `Constants.swift` - App constants
- `HeartAlertsApp.swift` - App entry point
- `AppDelegate.swift` - Notification setup

### Documentation
- `CLAUDE.md` - This file (development guidance)
- `ROADMAP.md` - Product roadmap (6-month plan)
- `REFACTORING.md` - Refactoring plan and checklist
