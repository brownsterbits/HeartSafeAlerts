# Apple Watch Heart Rate Integration Issue

## Context

HeartSafeAlerts is an iOS app that monitors heart rate and triggers alerts when readings go outside configured thresholds (e.g., below 60 or above 100 BPM).

**Working:** Bluetooth LE heart rate monitors (chest straps, etc.) provide real-time data every 1-2 seconds via CoreBluetooth. Alerts trigger immediately.

**Problem:** Apple Watch integration via HealthKit does not provide real-time data.

## The Issue

Apple Watch only syncs heart rate data to iPhone HealthKit every **5-25 minutes** in normal use. We observed gaps as long as 24 minutes between samples.

This makes Apple Watch unsuitable for real-time alerting - by the time we see a dangerous heart rate reading, it could be 20+ minutes old.

## What We Tried

1. **HKAnchoredObjectQuery** - Listens for new HealthKit samples. Works, but only fires when Watch syncs (every 5-25 min).

2. **HKSampleQuery polling** - Fetch latest sample every 30 seconds. Returns same stale data until Watch syncs.

3. **Background App Refresh** - Enabled on both iPhone and Watch. No significant improvement.

## Why This Happens

Apple limits background heart rate sampling to preserve Watch battery. Frequent readings only occur during:
- Active Workout sessions (every 3-5 seconds)
- Heart Rate app open on Watch (immediate, but stops when closed)

There is no iOS API or setting to request more frequent sampling from a paired Apple Watch.

## Potential Solutions

1. **Build a watchOS companion app** - A Watch app can request heart rate readings directly using `HKHealthStore.startWatchApp(with:)` or run a workout session. This is the proper solution but requires significant development.

2. **Instruct users to start a Workout** - During an active Workout on Watch, data syncs every few seconds. Could add UI prompting users to start "Other" workout for monitoring sessions.

3. **Accept the limitation** - Keep Apple Watch as a "check your recent heart rate" feature with clear disclaimers that it's not real-time. Not suitable for critical alerting.

4. **Remove Apple Watch support** - Until watchOS companion app is built, remove the option to avoid misleading users about monitoring capability.

## Technical Details

- iOS 18.4+, watchOS 11+
- Using HealthKit framework with read-only access to `HKQuantityType.heartRate`
- Watch and iPhone on same Apple ID, properly paired
- HealthKit authorization granted

## Question for Review

Is there any approach we're missing to get more frequent heart rate data from Apple Watch without building a watchOS app? Or is the watchOS companion app the only viable path for real-time monitoring?
