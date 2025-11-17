import Foundation
import CoreBluetooth
import AVFoundation

enum Constants {
    // Bluetooth
    static let heartRateServiceUUID = CBUUID(string: "180D")
    static let heartRateMeasurementUUID = CBUUID(string: "2A37")
    
    // Heart Rate Limits
    static let minHeartRateLimit = 40
    static let maxHeartRateLimit = 200
    static let defaultMinHeartRate = 60
    static let defaultMaxHeartRate = 100
    
    // Alert Settings
    static let alertSoundID: SystemSoundID = 1304
    static let defaultAlertCooldown: TimeInterval = 5
    static let defaultNotificationCooldown: TimeInterval = 60
    
    // UserDefaults Keys
    static let minHeartRateKey = "minHeartRate"
    static let maxHeartRateKey = "maxHeartRate"
    static let alertsEnabledKey = "alertsEnabled"
    static let soundAlertsEnabledKey = "soundAlertsEnabled"
    static let vibrationAlertsEnabledKey = "vibrationAlertsEnabled"
    static let backgroundNotificationsEnabledKey = "backgroundNotificationsEnabled"
    
    // Notification
    static let notificationCategoryIdentifier = "HEART_ALERT"
    static let viewActionIdentifier = "VIEW_ACTION"
    
    // UI
    static let connectionTimeout: TimeInterval = 30
    
    // Version Info
    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    static var fullVersionString: String {
        "Version \(appVersion) (Build \(buildNumber))"
    }

    // App Store metadata
    static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Heart Alerts"
    }
}
