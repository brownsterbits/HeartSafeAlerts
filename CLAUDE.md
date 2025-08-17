# HeartSafeAlerts iOS Project

## Project Setup
This is an iOS SwiftUI application for heart rate monitoring and alerts.

## Build Commands
```bash
# Build the project
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -configuration Debug build

# Clean build folder
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts clean

# Build for release
xcodebuild -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -configuration Release build
```

## Test Commands
```bash
# Run unit tests
xcodebuild test -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# Run UI tests
xcodebuild test -project HeartSafeAlerts.xcodeproj -scheme HeartSafeAlerts -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' -only-testing:HeartSafeAlertsUITests
```

## Development Notes
- Project uses SwiftUI for the UI framework
- Includes Bluetooth functionality for heart rate monitoring
- Has premium features with in-app purchases
- No SwiftLint currently configured