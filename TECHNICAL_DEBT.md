# HeartSafeAlerts Technical Debt

**Last Updated:** 2025-01-19
**Status:** Post-v2.0 tracking for future maintenance releases

This document tracks code quality improvements, refactoring opportunities, and technical debt items identified after v2.0 App Store submission. These are non-critical improvements that can be addressed in future maintenance releases.

---

## Priority: Low (Polish & Best Practices)

### 1. Extract Magic Numbers to Constants

**Issue:** Grace period and stale data thresholds are hardcoded in `BluetoothManager.swift`

**Current State:**
- Line 32: `Date().timeIntervalSince(lastUpdate) > 5` (stale threshold)
- Line 37: `Date().timeIntervalSince(connectionTime) > 5` (grace period)

**Proposed Fix:**
Add to `Constants.swift`:
```swift
// Bluetooth Timing
static let staleDataThreshold: TimeInterval = 5.0
static let connectionGracePeriod: TimeInterval = 5.0
```

Update `BluetoothManager.swift`:
```swift
var isStale: Bool {
    guard isConnected else { return false }
    guard let lastUpdate = lastUpdate else { return true }
    return Date().timeIntervalSince(lastUpdate) > Constants.staleDataThreshold
}

var hasGracePeriodExpired: Bool {
    guard let connectionTime = connectionTime else { return true }
    return Date().timeIntervalSince(connectionTime) > Constants.connectionGracePeriod
}
```

**Impact:** Low - Improves maintainability, no functional change
**Effort:** 5 minutes
**Files:** `Constants.swift`, `BluetoothManager.swift`

---

### 2. Replace Deprecated NavigationView with NavigationStack

**Issue:** Using deprecated `NavigationView` (iOS 13-15 API) instead of modern `NavigationStack` (iOS 16+)

**Current State:**
- `ContentView.swift:54` - Uses `NavigationView`
- `SettingsView.swift:9` - Uses `NavigationView`

**Proposed Fix:**
Replace all instances of:
```swift
NavigationView {
    // content
}
```

With:
```swift
NavigationStack {
    // content
}
```

**Impact:** Low - Cosmetic modernization, NavigationView still works fine
**Effort:** 2 minutes (simple find/replace)
**Files:** `ContentView.swift`, `SettingsView.swift`

**Note:** App targets iOS 18.4+, so NavigationStack is definitely available (introduced in iOS 16.0)

---

## Priority: Very Low (Nice to Have)

### 3. Bluetooth Heart Rate Flag Validation

**Issue:** BLE heart rate parsing ignores additional flags beyond 16-bit format detection

**Current State:**
- Only checks bit 0 (heart rate format: 8-bit vs 16-bit)
- Ignores sensor contact status (bits 1-2)
- Ignores energy expended present flag (bit 3)
- Ignores RR-Interval present flag (bit 4)
- No validation for invalid readings (bpm = 0 or 255)

**Proposed Enhancement:**
Add validation and status checking:
```swift
// In BluetoothManager.swift peripheral:didUpdateValueFor:
let flags = data[0]
let hasEnergyExpended = (flags & 0x08) != 0
let hasSensorContact = (flags & 0x06) != 0
let sensorContactSupported = (flags & 0x04) != 0
let sensorIsInContact = (flags & 0x02) != 0

// Validate reading
guard heartRate > 0 && heartRate < 255 else {
    print("⚠️ Invalid heart rate reading: \(heartRate)")
    return
}

// Optional: Check sensor contact if supported
if sensorContactSupported && !sensorIsInContact {
    print("⚠️ Sensor not in proper contact")
    // Could show warning in UI
}
```

**Impact:** Very Low - Defensive programming, adds robustness but app works fine without it
**Effort:** 30 minutes (research BLE spec, implement, test)
**Files:** `BluetoothManager.swift`

**Reference:** Bluetooth Heart Rate Measurement Characteristic (0x2A37) specification

---

### 4. HealthKit Query Optimization

**Issue:** `HKAnchoredObjectQuery` uses `predicate: nil`, which grabs all heart rate samples

**Current State:**
```swift
let query = HKAnchoredObjectQuery(
    type: heartRateType,
    predicate: nil,  // Gets all samples
    anchor: anchor,
    limit: HKObjectQueryNoLimit
) { ... }
```

**Proposed Enhancement:**
Filter to recent samples only (e.g., last 24 hours):
```swift
let calendar = Calendar.current
let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: Date())
let predicate = HKQuery.predicateForSamples(
    withStart: oneDayAgo,
    end: Date(),
    options: .strictStartDate
)

let query = HKAnchoredObjectQuery(
    type: heartRateType,
    predicate: predicate,  // Only recent samples
    anchor: anchor,
    limit: HKObjectQueryNoLimit
) { ... }
```

**Impact:** Very Low - Potential battery/CPU optimization, but anchored queries are already efficient
**Effort:** 10 minutes
**Files:** `HealthKitManager.swift`

**Note:** Anchored queries only return new samples after the anchor, so this may be premature optimization.

---

### 5. SessionStatistics Range Recalculation Optimization

**Issue:** `recalculateRangeTimes()` iterates through all samples (O(n)) when thresholds change

**Current State:**
- Works fine for typical sessions (30-60 minutes = 1800-3600 samples)
- Recalculation only happens when user manually changes thresholds
- Not a performance bottleneck in practice

**Proposed Enhancement (if ever needed):**
- Use interval tree or segmented tracking for very long sessions
- Pre-calculate boundary crossings during insertion

**Impact:** Very Low - Premature optimization for non-existent problem
**Effort:** 2-4 hours (probably not worth it)
**Files:** `SessionStatistics.swift`

**Decision:** NOT RECOMMENDED - Complexity outweighs minimal benefit

---

## Items Already Fixed (Incorrectly Reported by Code Review)

### ✅ UserNotifications Permission Request
- **Status:** Already implemented
- **Location:** `AppDelegate.swift:12` calls `requestNotificationPermissions()`
- **Implementation:** Requests authorization immediately on app launch (line 21)

### ✅ Background Modes Configuration
- **Status:** Already configured
- **Location:** `Info.plist` contains `bluetooth-central` in `UIBackgroundModes` array
- **Implementation:** Allows Bluetooth to work in background

### ✅ Dark Mode Support
- **Status:** Already implemented
- **Location:** Removed forced light mode in v2.0 refactoring
- **Implementation:** Respects system dark/light mode preference

---

## Tracking

Use this document to:
1. Track code quality improvements discovered during code reviews
2. Plan future maintenance releases
3. Prioritize polish items when time permits

**Next Steps:**
- Items #1 and #2 are good candidates for a future v2.0.1 maintenance release
- Items #3-5 are "if we ever need them" enhancements
- Continue adding items as discovered during development

**Source:** Issues identified during Grok 4.1 code review (2025-01-19)
