# HeartSafeAlerts

**Real-time heart rate monitoring that keeps your loved ones in the loop**

HeartSafeAlerts is an iOS app that monitors your heart rate via Bluetooth LE heart rate monitors or Apple Watch, providing real-time alerts when your heart rate goes outside your target range.

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2018.4%2B-blue.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

### ✅ Free Tier (All Features)
- **Dual Data Sources**: Connect via Bluetooth LE heart rate monitors OR Apple Watch via HealthKit
- **Automatic Source Selection**: App intelligently picks the best available data source
- **Custom Thresholds**: Set your own min/max heart rate limits
- **Real-Time Alerts**: Sound, vibration, and push notifications when out of range
- **Session Statistics**: Track min/max/avg BPM, time in/out of range during your session
- **Dark Mode**: Full support for iOS light and dark appearance
- **Accessibility**: VoiceOver support and reduce motion compatibility

### 🚀 Coming Soon: Care Circle (Premium)
_$2.99/month or $19.99/year_

- **Alert Escalation**: Automatically notify trusted contacts when you're out of range
- **Check-in Workflow**: "I'm okay" / "Need help" responses
- **Weekly Summaries**: Health reports sent to your care circle
- **Historical Trends**: Export data for doctor visits
- **Up to 5 Circle Members**: Keep your loved ones informed

## Screenshots

_Coming soon - App Store screenshots will be added here_

## Requirements

- iOS 18.4 or later
- Xcode 16+ (for development)
- Swift 6.0+
- Compatible Bluetooth LE heart rate monitor (e.g., Polar H10, Wahoo TICKR) OR Apple Watch

## Installation

### From App Store
_Coming soon - App Store link will be added here_

### From Source

1. Clone the repository:
```bash
git clone https://github.com/brownsterbits/HeartSafeAlerts.git
cd HeartSafeAlerts
```

2. Open in Xcode:
```bash
open HeartSafeAlerts.xcodeproj
```

3. Select your target device or simulator

4. Build and run (⌘R)

## Architecture

HeartSafeAlerts uses a clean, modular architecture with separation of concerns:

### Core Managers
- **HeartRateMonitor**: Coordinator that manages data flow and orchestrates other managers
- **BluetoothManager**: Handles all CoreBluetooth operations (scanning, connecting, data parsing)
- **HealthKitManager**: Handles Apple Watch integration via HealthKit
- **AlertManager**: Manages alert logic, thresholds, cooldowns, and notifications
- **SessionStatistics**: Tracks session metrics (min/max/avg, time in/out of range)

### Data Flow
```
Bluetooth Device OR Apple Watch
         ↓
BluetoothManager OR HealthKitManager
         ↓
   HeartRateMonitor (coordinator)
         ↓
    AlertManager → Notifications/Sounds/Vibrations
         ↓
  SessionStatistics → UI Updates
```

## Tech Stack

- **Language**: Swift 6.0+ with strict concurrency checking
- **UI**: SwiftUI
- **Frameworks**:
  - CoreBluetooth (BLE heart rate monitors)
  - HealthKit (Apple Watch integration)
  - UserNotifications (background alerts)
  - AVFoundation (sound playback)
  - Combine (reactive data flow)

## Documentation

- [ROADMAP.md](ROADMAP.md) - Product roadmap and strategic vision
- [REFACTORING.md](REFACTORING.md) - Technical refactoring history
- [CLAUDE.md](CLAUDE.md) - Developer guide for AI assistants

## Development

### Project Structure
```
HeartSafeAlerts/
├── HeartSafeAlerts/              # Main app source
│   ├── HeartRateMonitor.swift    # Main coordinator
│   ├── BluetoothManager.swift    # BLE handling
│   ├── HealthKitManager.swift    # Apple Watch integration
│   ├── AlertManager.swift        # Alert logic
│   ├── SessionStatistics.swift   # Session metrics
│   ├── ContentView.swift         # Main UI
│   ├── SettingsView.swift        # Settings UI
│   ├── SessionStatsView.swift    # Stats display
│   └── CareCirclePreviewView.swift # Premium feature preview
├── HeartSafeAlertsTests/         # Unit tests
└── HeartSafeAlertsUITests/       # UI tests
```

### Building

**Simulator (iPhone 16 recommended):**
```bash
xcodebuild -project HeartSafeAlerts.xcodeproj \
  -scheme HeartSafeAlerts \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

**Physical Device (required for Bluetooth testing):**
```bash
xcodebuild -project HeartSafeAlerts.xcodeproj \
  -scheme HeartSafeAlerts \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  build
```

### Testing

Bluetooth functionality requires a physical iOS device and compatible heart rate monitor. Apple Watch functionality can be tested with a paired Apple Watch.

**Note**: Bluetooth LE does not work reliably in the iOS Simulator.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

### Phase 1: Foundation & Free Tier ✅ Complete
- Remove premium gating
- Add HealthKit/Apple Watch support
- Enable dark mode
- Session statistics

### Phase 2: Care Circle v1 (Coming Soon)
- Backend infrastructure (Firebase)
- Invite system for circle members
- Alert escalation workflow
- Weekly health summaries
- Premium subscription via StoreKit

### Phase 3: Apple Watch App
- Native watchOS app
- On-wrist acknowledgment
- Watch complications
- Offline resilience

See [ROADMAP.md](ROADMAP.md) for complete details.

## Privacy & Health Data

HeartSafeAlerts takes your privacy seriously:

- **Local First**: All heart rate monitoring happens on-device
- **No Account Required**: Free tier requires no registration
- **HealthKit Permissions**: We only access heart rate data, nothing else
- **No Tracking**: We don't track your usage or sell your data
- **Care Circle Opt-In**: Future premium features require explicit consent

**Important**: This app is not a medical device and should not be used for medical diagnosis or treatment. Always consult healthcare professionals for medical advice.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Chad Brown - [brownsterbits](https://github.com/brownsterbits)

## Acknowledgments

- Built with SwiftUI and modern Swift concurrency
- Heart rate monitoring via Bluetooth SIG Heart Rate Service (0x180D)
- Apple Watch integration via HealthKit
- Developed with assistance from [Claude Code](https://claude.com/claude-code)

## Support

For issues, questions, or feature requests, please:
- Open an issue on [GitHub Issues](https://github.com/brownsterbits/HeartSafeAlerts/issues)
- Contact: heartsafe@brownster.com (coming soon)

---

**Status**: v1.1 - Ready for App Store submission 🚀

Made with ❤️ for those who care about their heart health
