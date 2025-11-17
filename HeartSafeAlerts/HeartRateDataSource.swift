import Foundation

/// Represents the source of heart rate data
enum HeartRateDataSource: String, CaseIterable, Identifiable {
    case bluetooth = "Bluetooth Monitor"
    case appleWatch = "Apple Watch"
    case automatic = "Automatic"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .bluetooth:
            return "Connect to external Bluetooth heart rate monitor"
        case .appleWatch:
            return "Use heart rate data from Apple Watch via HealthKit"
        case .automatic:
            return "Automatically select best available source"
        }
    }

    var icon: String {
        switch self {
        case .bluetooth:
            return "antenna.radiowaves.left.and.right"
        case .appleWatch:
            return "applewatch"
        case .automatic:
            return "wand.and.stars"
        }
    }
}
