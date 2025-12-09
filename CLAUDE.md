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

## Architecture (Post-Refactoring v1.1)

### Core Managers

**HeartRateMonitor** (`HeartRateMonitor.swift`)
- Coordinator `ObservableObject` that orchestrates between data sources and managers
- Manages dual data sources (Bluetooth + HealthKit) with automatic selection
- Features:
  - Automatic source fallback (Bluetooth preferred, HealthKit backup)
  - User-configurable source selection (Bluetooth/Apple Watch/Automatic)
  - Combines data from BluetoothManager and HealthKitManager
  - Delegates alert checking to AlertManager
  - Updates SessionStatistics with incoming data
  - 66% reduction in complexity (442 lines → 299 lines)

**BluetoothManager** (`BluetoothManager.swift`)
- Handles all CoreBluetooth operations
- Implements `CBCentralManagerDelegate` and `CBPeripheralDelegate`
- Features:
  - Scanning for Heart Rate Service (UUID 180D)
  - Automatic connection and reconnection
  - BLE heart rate data parsing (8-bit and 16-bit formats)
  - Stale data detection (>5 seconds without update)
  - Grace period (5 seconds after connection)
  - Connection timeout handling

**HealthKitManager** (`HealthKitManager.swift`)
- Handles Apple Watch integration via HealthKit
- Features:
  - Authorization request flow
  - Continuous heart rate monitoring via HKAnchoredObjectQuery
  - Real-time updates from Apple Watch
  - Swift 6 concurrency-safe with @MainActor
  - One-time fetch capability for latest heart rate

**AlertManager** (`AlertManager.swift`)
- Manages all alert logic separated from data sources
- Features:
  - Configurable thresholds (min/max BPM)
  - Alert cooldown periods (5s local, 60s notifications)
  - Sound alerts (system sound ID 1304)
  - Vibration alerts (haptic feedback)
  - Background notifications
  - Grace period and stale data checks
  - All alerts now FREE (no premium gating)

**SessionStatistics** (`SessionStatistics.swift`)
- Tracks session metrics separate from monitoring logic
- Features:
  - Min/Max/Average BPM calculation
  - Time in/out of range tracking
  - Session duration formatting
  - Threshold-aware statistics
  - Reset on new session

**BluetoothState** (`BluetoothState.swift`)
- Enum representing all connection states
- States: unknown, poweredOff, unauthorized, unsupported, idle, scanning, connecting, connected(deviceName), disconnected, error(message)

**HeartRateDataSource** (`HeartRateDataSource.swift`)
- Enum for data source selection: bluetooth, appleWatch, automatic
- Used in Settings picker for user preference

### UI Components

**ContentView** (`ContentView.swift`)
- Main UI showing real-time heart rate with animated heart icon
- Status banner with color coding (gray/blue/orange/red/green)
- Tap-to-reconnect functionality when disconnected
- SessionStatsView integration (shown when data available)
- Accessibility support (VoiceOver, reduce motion)

**SettingsView** (`SettingsView.swift`)
- Heart rate threshold configuration (sliders)
- Data source picker (Bluetooth/Apple Watch/Automatic)
- Alert settings (all FREE, no premium gating)
- Device status display
- Care Circle preview (teaser for future premium)
- About section

**SessionStatsView** (`SessionStatsView.swift`)
- Displays session statistics in ContentView
- Shows min/max/avg BPM
- Time in/out of range with formatted durations
- Conditionally shown only when data exists

**CareCirclePreviewView** (`CareCirclePreviewView.swift`)
- Teases future premium feature in Settings
- Shows "COMING SOON" badge
- Lists 4 key features with icons
- Displays $2.99/month pricing

### Current Feature Set (v1.1 - All FREE)
- ✅ Real-time heart rate monitoring
- ✅ Dual data sources: Bluetooth LE OR Apple Watch via HealthKit
- ✅ Automatic source selection with manual override
- ✅ Custom threshold configuration
- ✅ Sound alerts (system sound ID 1304)
- ✅ Vibration alerts (haptic feedback)
- ✅ Background notifications
- ✅ Session statistics (min/max/avg, time in/out of range)
- ✅ Dark mode support
- ✅ Stale data detection and grace periods

**Future Premium Feature (v1.2+):**
- **Care Circle** ($2.99/month or $19.99/year):
  - Invite up to 5 trusted contacts
  - Automatic alert escalation to circle members
  - Check-in workflow ("I'm okay" / "Need help")
  - Weekly health summaries for circle
  - Historical data and trends
  - Export reports for doctors

### Data Flow
1. User launches app → `HeartRateMonitor.startMonitoring()`
2. Based on data source setting:
   - **Bluetooth**: `BluetoothManager` scans for Heart Rate Service (180D), connects, subscribes to characteristic (2A37)
   - **Apple Watch**: `HealthKitManager` requests authorization, starts HKAnchoredObjectQuery for continuous heart rate
   - **Automatic**: Tries Bluetooth first, falls back to HealthKit if Bluetooth unavailable
3. Data updates flow through Combine publishers:
   - `BluetoothManager.$currentHeartRate` → `HeartRateMonitor`
   - `HealthKitManager.$currentHeartRate` → `HeartRateMonitor`
4. `HeartRateMonitor` handles updates:
   - Updates published properties for UI
   - Adds sample to `SessionStatistics`
   - Calls `AlertManager.checkHeartRate()` to evaluate alerts
5. `AlertManager` triggers alerts if out of range (with cooldowns)
6. UI updates automatically via `@Published` properties

### State Management
- `@StateObject` for view-owned objects (HeartRateMonitor in App)
- `@EnvironmentObject` for passing monitor down the view hierarchy
- `@Published` properties in ObservableObject classes for reactive updates
- `@AppStorage` for direct UserDefaults binding (backgroundNotificationsEnabled)
- UserDefaults for persistence (thresholds, alert preferences, data source selection)
- Combine framework for reactive data flow between managers

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
- Stale data threshold: 5 seconds without update (⚠️ currently hardcoded in BluetoothManager)
- Grace period: 5 seconds after connection (⚠️ currently hardcoded in BluetoothManager)

**Note:** See `TECHNICAL_DEBT.md` for planned extraction of hardcoded timing values to Constants.

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

### Current Version: v2.0 ✅
**Status:** Submitted to App Store (January 16, 2025)
**Refactoring:** ✅ COMPLETE (see `REFACTORING.md`)

**What's Live in v2.0:**
- All features FREE (removed premium gating)
- Dual data sources (Bluetooth + Apple Watch via HealthKit)
- Session statistics tracking
- Dark mode support
- Modern SwiftUI architecture with separated managers
- Care Circle preview (teaser for future premium)

### Technical Debt & Future Improvements
See `TECHNICAL_DEBT.md` for tracked code quality improvements, including:
- Extract magic numbers to Constants (grace period, stale threshold)
- Replace deprecated NavigationView with NavigationStack
- Optional Bluetooth validation enhancements

### Upcoming Features (See ROADMAP.md)
- **Phase 2 (Weeks 5-12):** Care Circle MVP with subscription ($2.99/month)
- **Phase 3 (Weeks 13-20):** Apple Watch companion app
- **Phase 4 (Weeks 21-26):** Intelligence layer (pattern detection, personalization)

## Current Limitations
- No landscape orientation support
- No historical data storage (coming in Phase 2)
- No Firebase integration active (intentionally privacy-first)
- No SwiftLint configuration
- See `TECHNICAL_DEBT.md` for minor code quality improvements

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
- `REFACTORING.md` - Refactoring plan and checklist (v2.0 - COMPLETE)
- `TECHNICAL_DEBT.md` - Code quality improvements and polish items for future releases
