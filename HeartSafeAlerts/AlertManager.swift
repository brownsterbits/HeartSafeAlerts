import Foundation
import UserNotifications
import AVFoundation
import UIKit

/// Manages all alert logic including thresholds, cooldowns, and notifications
@MainActor
class AlertManager: ObservableObject {
    // MARK: - Published Properties

    @Published var alertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(alertsEnabled, forKey: Constants.alertsEnabledKey)
        }
    }

    @Published var soundAlertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(soundAlertsEnabled, forKey: Constants.soundAlertsEnabledKey)
        }
    }

    @Published var vibrationAlertsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(vibrationAlertsEnabled, forKey: Constants.vibrationAlertsEnabledKey)
        }
    }

    @Published var backgroundNotificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(backgroundNotificationsEnabled, forKey: Constants.backgroundNotificationsEnabledKey)
        }
    }

    @Published var minHeartRate: Int = Constants.defaultMinHeartRate {
        didSet {
            UserDefaults.standard.set(minHeartRate, forKey: Constants.minHeartRateKey)
        }
    }

    @Published var maxHeartRate: Int = Constants.defaultMaxHeartRate {
        didSet {
            UserDefaults.standard.set(maxHeartRate, forKey: Constants.maxHeartRateKey)
        }
    }

    // MARK: - Private Properties

    private var lastAlertTime: Date?
    private var lastNotificationTime: Date?

    // MARK: - Initialization

    init() {
        loadPreferences()
        setupAudioSession()
    }

    private func loadPreferences() {
        minHeartRate = UserDefaults.standard.object(forKey: Constants.minHeartRateKey) as? Int ?? Constants.defaultMinHeartRate
        maxHeartRate = UserDefaults.standard.object(forKey: Constants.maxHeartRateKey) as? Int ?? Constants.defaultMaxHeartRate
        alertsEnabled = UserDefaults.standard.object(forKey: Constants.alertsEnabledKey) as? Bool ?? false
        soundAlertsEnabled = UserDefaults.standard.object(forKey: Constants.soundAlertsEnabledKey) as? Bool ?? false
        vibrationAlertsEnabled = UserDefaults.standard.object(forKey: Constants.vibrationAlertsEnabledKey) as? Bool ?? false

        if UserDefaults.standard.object(forKey: Constants.backgroundNotificationsEnabledKey) == nil {
            UserDefaults.standard.set(false, forKey: Constants.backgroundNotificationsEnabledKey)
        }
        backgroundNotificationsEnabled = UserDefaults.standard.bool(forKey: Constants.backgroundNotificationsEnabledKey)
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Public Methods

    /// Check heart rate and trigger alerts if needed
    func checkHeartRate(_ bpm: Double, isStale: Bool, hasGracePeriod: Bool) {
        guard alertsEnabled else { return }
        guard !isStale && !hasGracePeriod else { return }

        let isOutOfRange = bpm < Double(minHeartRate) || bpm > Double(maxHeartRate)
        guard isOutOfRange else { return }

        // Trigger local alerts (sound/vibration)
        if shouldTriggerLocalAlert() {
            playLocalAlerts()
            lastAlertTime = Date()
        }

        // Trigger background notifications
        if shouldTriggerNotification() {
            sendNotification(bpm: bpm)
            lastNotificationTime = Date()
        }
    }

    // MARK: - Private Alert Methods

    private func shouldTriggerLocalAlert() -> Bool {
        guard let lastTime = lastAlertTime else { return true }
        return Date().timeIntervalSince(lastTime) >= Constants.defaultAlertCooldown
    }

    private func shouldTriggerNotification() -> Bool {
        guard backgroundNotificationsEnabled else { return false }
        guard let lastTime = lastNotificationTime else { return true }
        return Date().timeIntervalSince(lastTime) >= Constants.defaultNotificationCooldown
    }

    private func playLocalAlerts() {
        if soundAlertsEnabled {
            AudioServicesPlaySystemSound(Constants.alertSoundID)
        }

        if vibrationAlertsEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }
    }

    private func sendNotification(bpm: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate Alert!"

        if bpm < Double(minHeartRate) {
            content.body = "Your heart rate is too low: \(Int(bpm)) BPM (minimum: \(minHeartRate) BPM)"
        } else {
            content.body = "Your heart rate is too high: \(Int(bpm)) BPM (maximum: \(maxHeartRate) BPM)"
        }

        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryIdentifier

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}
