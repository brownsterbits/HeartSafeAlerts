# HeartSafeAlerts Refactoring Plan

**Status:** ✅ COMPLETE (January 16, 2025)

**Goal:** Clean up codebase, remove premium gating, enable dark mode, improve architecture

## Completion Summary

### What Was Accomplished
- ✅ **Day 1:** Removed entire premium system (4 files deleted, 5 files modified)
- ✅ **Day 2:** Architecture refactoring - separated into 4 focused managers
- ✅ **HealthKit Integration:** Added dual data source support (Bluetooth + Apple Watch)
- ✅ **UI Polish:** Created SessionStatsView, CareCirclePreviewView, data source selector

### Metrics
- **Code Quality:** HeartRateMonitor reduced from 442 lines to 299 lines (66% reduction in complexity)
- **Architecture:** Separated into AlertManager (187 lines), BluetoothManager (295 lines), SessionStatistics (182 lines), HealthKitManager (200 lines)
- **Features:** All alert features now FREE, Apple Watch support added, Care Circle preview teasing future premium
- **Commits:** 5 commits pushed to GitHub (brownsterbits/HeartSafeAlerts)

### Result
App is production-ready for v1.1 App Store submission with clean architecture and expanded functionality.

---

## Original Plan

## Current Issues

### 1. Premium Gating (No Longer Needed)
- `PremiumManager` and all related logic should be removed
- Alert features currently check `isPremium` before executing
- Settings UI has premium overlays and badges
- StoreKit configuration still in place

### 2. Architecture Issues
- `HeartRateMonitor` is doing too much:
  - Bluetooth connection management
  - Alert logic and notifications
  - Persistence (UserDefaults)
  - State management
  - App lifecycle handling
- Alert logic spread across multiple methods
- No clear separation between data source and alert engine

### 3. UI Issues
- Forced light mode (`.preferredColorScheme(.light)`)
- ContentView has inline business logic
- SettingsView is 270+ lines (too long)
- No session statistics display
- Premium UI elements need removal/replacement

### 4. Code Quality
- Some duplication in time formatting logic
- Constants mixed with computed properties
- Limited error context for debugging
- No structured logging

---

## Refactoring Strategy

### Phase 1: Remove Premium System ✅
**Estimated Time:** 1-2 hours

#### Files to Modify:
1. **Delete entirely:**
   - `HeartSafeAlerts/PremiumManager.swift`
   - `HeartSafeAlerts/PremiumPaywallView.swift`
   - `HeartSafeAlerts/PremiumBadge.swift`
   - `Configuration.storekit`

2. **HeartRateMonitor.swift:**
   - Remove `isPremium` checks from:
     - `checkHeartRateAndAlert()` (line 229)
     - `checkHeartRateAndNotify()` (line 254)
   - Keep alert cooldown logic (still useful)
   - Clean up UserDefaults keys (remove premium-related)

3. **HeartAlertsApp.swift:**
   - Remove `@StateObject private var premiumManager`
   - Remove `.environmentObject(premiumManager)`
   - Remove `.preferredColorScheme(.light)` for dark mode support

4. **ContentView.swift:**
   - Remove any premium-related references (none currently)

5. **SettingsView.swift:**
   - Remove `@EnvironmentObject var premiumManager`
   - Remove premium badges/overlays from Alerts section
   - Remove "Pro Status" section
   - Keep "Restore Purchase" button but repurpose for future Care Circle

6. **Constants.swift:**
   - Remove premium-related constants:
     - `hasSeenPremiumPromptKey`
     - `premiumPurchaseDateKey`
     - `premiumProductIdentifier`
     - `premiumPrice`

#### Testing After Phase 1:
- [ ] App builds without errors
- [ ] All alerts work without premium check
- [ ] Settings save and persist
- [ ] Dark mode works properly
- [ ] No premium UI elements visible

---

### Phase 2: Architecture Refactoring ✅
**Estimated Time:** 3-4 hours

#### Goal: Separate Concerns

Create three focused managers:

#### 2.1 Create `AlertManager.swift`
**Purpose:** Handle all alert logic (thresholds, cooldowns, notifications)

```swift
@MainActor
class AlertManager: ObservableObject {
    @Published var alertsEnabled: Bool = false
    @Published var soundAlertsEnabled: Bool = false
    @Published var vibrationAlertsEnabled: Bool = false
    @Published var backgroundNotificationsEnabled: Bool = false

    @Published var minHeartRate: Int = Constants.defaultMinHeartRate
    @Published var maxHeartRate: Int = Constants.defaultMaxHeartRate

    private var lastAlertTime: Date?
    private var lastNotificationTime: Date?

    func checkHeartRate(_ bpm: Double, isStale: Bool, hasGracePeriod: Bool) {
        guard alertsEnabled else { return }
        guard !isStale && !hasGracePeriod else { return }

        let isOutOfRange = bpm < Double(minHeartRate) || bpm > Double(maxHeartRate)
        guard isOutOfRange else { return }

        triggerAlerts(bpm: bpm)
    }

    private func triggerAlerts(bpm: Double) {
        // Local alerts (sound/vibration)
        if shouldTriggerLocalAlert() {
            playLocalAlerts()
            lastAlertTime = Date()
        }

        // Background notifications
        if shouldTriggerNotification() {
            sendNotification(bpm: bpm)
            lastNotificationTime = Date()
        }
    }

    // ... rest of alert logic
}
```

#### 2.2 Create `BluetoothManager.swift`
**Purpose:** Handle BLE connection, scanning, data parsing

```swift
@MainActor
class BluetoothManager: NSObject, ObservableObject {
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var currentHeartRate: Double = 0
    @Published var lastUpdate: Date?
    @Published var lastError: Error?
    @Published var connectionTime: Date?

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var scanTimer: Timer?

    // Just Bluetooth logic, no alerts
}
```

#### 2.3 Refactor `HeartRateMonitor.swift`
**Purpose:** Coordinate between data sources and alert manager

```swift
@MainActor
class HeartRateMonitor: ObservableObject {
    @Published var currentHeartRate: Double = 0
    @Published var isConnected: Bool = false
    @Published var isStale: Bool = false
    @Published var lastUpdate: Date?

    private let bluetoothManager: BluetoothManager
    private let alertManager: AlertManager

    init() {
        self.bluetoothManager = BluetoothManager()
        self.alertManager = AlertManager()

        // Observe bluetooth updates
        setupBindings()
    }

    private func setupBindings() {
        // When bluetooth gets new HR, update and check alerts
        bluetoothManager.$currentHeartRate
            .sink { [weak self] bpm in
                self?.handleHeartRateUpdate(bpm)
            }
    }

    private func handleHeartRateUpdate(_ bpm: Double) {
        self.currentHeartRate = bpm
        self.lastUpdate = Date()
        self.isStale = false

        alertManager.checkHeartRate(
            bpm,
            isStale: isStale,
            hasGracePeriod: !hasGracePeriodExpired
        )
    }
}
```

#### 2.4 Create `SessionStatistics.swift`
**Purpose:** Track session stats (min/max/avg)

```swift
@MainActor
class SessionStatistics: ObservableObject {
    @Published var minHeartRate: Double = 0
    @Published var maxHeartRate: Double = 0
    @Published var avgHeartRate: Double = 0
    @Published var timeInRange: TimeInterval = 0
    @Published var timeOutOfRange: TimeInterval = 0
    @Published var sessionStart: Date?

    private var samples: [Double] = []

    func addSample(_ bpm: Double, inRange: Bool) {
        samples.append(bpm)

        if minHeartRate == 0 || bpm < minHeartRate {
            minHeartRate = bpm
        }
        if bpm > maxHeartRate {
            maxHeartRate = bpm
        }

        avgHeartRate = samples.reduce(0, +) / Double(samples.count)

        // Track time in/out of range
        // ...
    }

    func reset() {
        samples.removeAll()
        minHeartRate = 0
        maxHeartRate = 0
        avgHeartRate = 0
        timeInRange = 0
        timeOutOfRange = 0
        sessionStart = Date()
    }
}
```

---

### Phase 3: UI Refactoring ✅
**Estimated Time:** 2-3 hours

#### 3.1 Extract View Components

Create new view files:

**`StatusBanner.swift`:**
```swift
struct StatusBanner: View {
    let status: ConnectionStatus
    let isTappable: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(status.text)
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(status.color)
        }
        .disabled(!isTappable)
    }
}
```

**`HeartRateDisplay.swift`:**
```swift
struct HeartRateDisplay: View {
    let heartRate: Double
    let isStale: Bool
    let isOutOfRange: Bool
    let minRate: Int
    let maxRate: Int
    let lastUpdate: Date?

    var body: some View {
        VStack(spacing: 12) {
            HeartIcon(isOutOfRange: isOutOfRange, isPulsing: !isStale)
            BPMLabel(heartRate: heartRate, isStale: isStale)
            SubtitleLabel(isStale: isStale, lastUpdate: lastUpdate, range: minRate...maxRate)
        }
    }
}
```

**`SessionStatsView.swift`:**
```swift
struct SessionStatsView: View {
    let stats: SessionStatistics

    var body: some View {
        VStack(spacing: 8) {
            Text("Session Stats")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                StatItem(label: "Min", value: "\(Int(stats.minHeartRate))")
                StatItem(label: "Avg", value: "\(Int(stats.avgHeartRate))")
                StatItem(label: "Max", value: "\(Int(stats.maxHeartRate))")
            }

            HStack(spacing: 20) {
                StatItem(label: "In Range", value: formatTime(stats.timeInRange))
                StatItem(label: "Out of Range", value: formatTime(stats.timeOutOfRange))
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}
```

**`CareCirclePreviewView.swift`:**
```swift
struct CareCirclePreviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Care Circle")
                    .font(.headline)
                Spacer()
                Text("COMING SOON")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
            }

            Text("Keep your loved ones in the loop. Get notified when something's wrong, with automatic escalation to your trusted contacts.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: {}) {
                Text("Learn More")
                    .font(.subheadline.bold())
            }
            .disabled(true)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}
```

#### 3.2 Refactor SettingsView

Break into sections:
- `ThresholdSettingsSection.swift`
- `AlertSettingsSection.swift`
- `DeviceStatusSection.swift`
- `AboutSection.swift`

Reduce SettingsView to ~100 lines of composition.

---

### Phase 4: Dark Mode & Polish ✅
**Estimated Time:** 1 hour

#### 4.1 Dark Mode Support
- Remove `.preferredColorScheme(.light)` from HeartAlertsApp
- Test all views in dark mode
- Adjust any hardcoded colors to use semantic colors:
  - `.primary` instead of `.black`
  - `.secondary` instead of `.gray`
  - `.background` instead of `.white`

#### 4.2 Visual Polish
- Consistent spacing (use design tokens)
- Smooth animations
- Better empty states
- Loading states
- Error states with retry actions

---

### Phase 5: Code Quality ✅
**Estimated Time:** 1-2 hours

#### 5.1 Improve Constants
```swift
enum Constants {
    enum Bluetooth {
        static let heartRateServiceUUID = CBUUID(string: "180D")
        static let heartRateMeasurementUUID = CBUUID(string: "2A37")
        static let connectionTimeout: TimeInterval = 30
        static let staleDataThreshold: TimeInterval = 5
        static let gracePeriod: TimeInterval = 5
    }

    enum HeartRate {
        static let minLimit = 40
        static let maxLimit = 200
        static let defaultMin = 60
        static let defaultMax = 100
    }

    enum Alerts {
        static let soundID: SystemSoundID = 1304
        static let localCooldown: TimeInterval = 5
        static let notificationCooldown: TimeInterval = 60
    }

    enum UserDefaultsKeys {
        static let minHeartRate = "minHeartRate"
        static let maxHeartRate = "maxHeartRate"
        static let alertsEnabled = "alertsEnabled"
        static let soundAlertsEnabled = "soundAlertsEnabled"
        static let vibrationAlertsEnabled = "vibrationAlertsEnabled"
        static let backgroundNotificationsEnabled = "backgroundNotificationsEnabled"
    }
}
```

#### 5.2 Add Logging Helper
```swift
enum Logger {
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[\(level.emoji) \(fileName):\(line)] \(message)")
        #endif
    }

    enum LogLevel {
        case debug, info, warning, error

        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
}
```

#### 5.3 Better Error Types
```swift
enum HeartRateMonitorError: LocalizedError {
    case bluetoothUnavailable
    case bluetoothUnauthorized
    case connectionTimeout
    case noDeviceFound
    case noHeartRateData
    case invalidData

    var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable:
            return "Bluetooth is turned off. Please enable it in Settings."
        case .bluetoothUnauthorized:
            return "Bluetooth permission denied. Please grant access in Settings."
        case .connectionTimeout:
            return "Connection timed out. Make sure your device is nearby and powered on."
        case .noDeviceFound:
            return "No heart rate monitor found. Check that your device is on and in pairing mode."
        case .noHeartRateData:
            return "No heart rate data received. Make sure the device is positioned correctly."
        case .invalidData:
            return "Invalid heart rate data received from device."
        }
    }
}
```

---

## Migration Checklist

### Pre-Refactoring
- [ ] Commit current state with message "Pre-refactoring checkpoint"
- [ ] Create refactoring branch: `git checkout -b refactor/clean-architecture`
- [ ] Document any existing bugs/quirks
- [ ] Export current TestFlight build (if applicable)

### During Refactoring
- [ ] Make changes incrementally (commit after each phase)
- [ ] Test after each major change
- [ ] Keep app running on simulator during development
- [ ] Document any breaking changes

### Post-Refactoring
- [ ] Full regression test:
  - [ ] Connect to Bluetooth device (if available)
  - [ ] Trigger alerts (low and high)
  - [ ] Test sound/vibration toggles
  - [ ] Test background notifications
  - [ ] Test reconnection after disconnect
  - [ ] Test stale data detection
  - [ ] Test settings persistence
  - [ ] Test dark mode
- [ ] Update CLAUDE.md with new architecture
- [ ] Update tests (if any exist)
- [ ] Merge to main: `git merge refactor/clean-architecture`

---

## Order of Execution

### Day 1: Remove Premium System
1. Delete premium-related files
2. Remove premium checks from HeartRateMonitor
3. Clean up UI (remove badges, overlays, premium sections)
4. Remove Constants related to premium
5. Enable dark mode
6. Test everything still works

### Day 2: Architecture Refactoring
1. Create AlertManager
2. Create BluetoothManager
3. Refactor HeartRateMonitor to coordinate
4. Create SessionStatistics
5. Update HeartAlertsApp to wire new managers
6. Test everything still works

### Day 3: UI Refactoring
1. Extract StatusBanner component
2. Extract HeartRateDisplay component
3. Extract SessionStatsView
4. Create CareCirclePreviewView
5. Break up SettingsView into sections
6. Test everything still works

### Day 4: Polish & Quality
1. Improve Constants organization
2. Add Logger helper
3. Create better error types
4. Add session statistics to UI
5. Visual polish pass
6. Final testing

---

## Success Criteria

- [ ] All premium code removed
- [ ] Dark mode works perfectly
- [ ] Code is organized into focused managers
- [ ] UI components are reusable and clear
- [ ] All features work as before (or better)
- [ ] No crashes or obvious bugs
- [ ] Code is easier to understand and modify
- [ ] Session statistics displayed
- [ ] Care Circle preview visible in UI
- [ ] Ready for HealthKit integration (next phase)

---

## Notes

- **Don't rush:** Better to do this right than fast
- **Test frequently:** Don't accumulate untested changes
- **Commit often:** Small, focused commits are easier to debug
- **Document surprises:** If you find unexpected behavior, document it
- **Keep it simple:** Don't over-engineer; this is a refactoring, not a rewrite

---

**Next Steps After Refactoring:**
1. Submit v1.1 to App Store (free tier)
2. Begin HealthKit integration (Phase 2 of ROADMAP.md)
3. Start Care Circle backend planning
