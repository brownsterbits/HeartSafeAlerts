import Foundation
import Combine

/// Coordinates heart rate monitoring between Bluetooth, alerts, and statistics
@MainActor
class HeartRateMonitor: ObservableObject {
    // MARK: - Managers

    let bluetoothManager: BluetoothManager
    let alertManager: AlertManager
    let sessionStatistics: SessionStatistics

    // MARK: - Published Properties (delegated to managers)

    @Published var currentHeartRate: Double = 0
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var lastUpdate: Date?
    @Published var isStale: Bool = false

    // Threshold settings (delegated to AlertManager)
    var minHeartRate: Int {
        get { alertManager.minHeartRate }
        set { alertManager.minHeartRate = newValue
              sessionStatistics.updateThresholds(min: newValue, max: alertManager.maxHeartRate)
        }
    }

    var maxHeartRate: Int {
        get { alertManager.maxHeartRate }
        set { alertManager.maxHeartRate = newValue
              sessionStatistics.updateThresholds(min: alertManager.minHeartRate, max: newValue)
        }
    }

    var alertsEnabled: Bool {
        get { alertManager.alertsEnabled }
        set { alertManager.alertsEnabled = newValue }
    }

    var soundAlertsEnabled: Bool {
        get { alertManager.soundAlertsEnabled }
        set { alertManager.soundAlertsEnabled = newValue }
    }

    var vibrationAlertsEnabled: Bool {
        get { alertManager.vibrationAlertsEnabled }
        set { alertManager.vibrationAlertsEnabled = newValue }
    }

    var backgroundNotificationsEnabled: Bool {
        get { alertManager.backgroundNotificationsEnabled }
        set { alertManager.backgroundNotificationsEnabled = newValue }
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// Whether a Bluetooth device is connected
    var isConnected: Bool {
        bluetoothManager.isConnected
    }

    var hasGracePeriodExpired: Bool {
        bluetoothManager.hasGracePeriodExpired
    }

    var isOutOfRange: Bool {
        guard isConnected else { return false }
        guard !isStale else { return false }
        guard hasGracePeriodExpired else { return false }
        return currentHeartRate < Double(minHeartRate) || currentHeartRate > Double(maxHeartRate)
    }

    // MARK: - Initialization

    init() {
        self.bluetoothManager = BluetoothManager()
        self.alertManager = AlertManager()
        self.sessionStatistics = SessionStatistics()

        setupBindings()
        sessionStatistics.startSession(
            minThreshold: alertManager.minHeartRate,
            maxThreshold: alertManager.maxHeartRate
        )
    }

    // MARK: - Setup

    private func setupBindings() {
        // Observe heart rate updates from Bluetooth
        bluetoothManager.$currentHeartRate
            .sink { [weak self] bpm in
                guard let self = self else { return }
                self.handleHeartRateUpdate(bpm)
            }
            .store(in: &cancellables)

        // Observe Bluetooth state changes
        bluetoothManager.$bluetoothState
            .sink { [weak self] state in
                self?.bluetoothState = state
            }
            .store(in: &cancellables)

        // Observe last update time from Bluetooth
        bluetoothManager.$lastUpdate
            .sink { [weak self] date in
                guard let self = self else { return }
                if let date = date {
                    self.lastUpdate = date
                }
            }
            .store(in: &cancellables)

        // Observe stale status
        bluetoothManager.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isStale = self.bluetoothManager.isStale
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func startMonitoring() {
        bluetoothManager.startMonitoring()
    }

    func stopMonitoring() {
        bluetoothManager.stopMonitoring()
    }

    func refreshConnection() {
        bluetoothManager.refreshConnection()
        sessionStatistics.reset()
        sessionStatistics.startSession(
            minThreshold: alertManager.minHeartRate,
            maxThreshold: alertManager.maxHeartRate
        )
    }

    // MARK: - Private Methods

    private func handleHeartRateUpdate(_ bpm: Double) {
        self.currentHeartRate = bpm

        // Update session statistics
        sessionStatistics.addSample(bpm)

        // Check alerts
        alertManager.checkHeartRate(
            bpm,
            isStale: isStale,
            hasGracePeriod: !hasGracePeriodExpired
        )
    }
}
