import Foundation
import Combine

/// Coordinates heart rate monitoring between data sources, alerts, and statistics
@MainActor
class HeartRateMonitor: ObservableObject {
    // MARK: - Managers

    let bluetoothManager: BluetoothManager
    let healthKitManager: HealthKitManager
    let alertManager: AlertManager
    let sessionStatistics: SessionStatistics

    // MARK: - Published Properties (delegated to managers)

    @Published var currentHeartRate: Double = 0
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var lastUpdate: Date?
    @Published var isStale: Bool = false
    @Published var dataSource: HeartRateDataSource = .automatic {
        didSet {
            UserDefaults.standard.set(dataSource.rawValue, forKey: "heartRateDataSource")
            handleDataSourceChange()
        }
    }
    @Published var activeSource: HeartRateDataSource?

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

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

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
        self.healthKitManager = HealthKitManager()
        self.alertManager = AlertManager()
        self.sessionStatistics = SessionStatistics()

        // Load saved data source preference
        if let savedSource = UserDefaults.standard.string(forKey: "heartRateDataSource"),
           let source = HeartRateDataSource(rawValue: savedSource) {
            self.dataSource = source
        }

        setupBindings()
        sessionStatistics.startSession(
            minThreshold: alertManager.minHeartRate,
            maxThreshold: alertManager.maxHeartRate
        )

        // Check HealthKit authorization
        healthKitManager.checkAuthorizationStatus()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Observe heart rate updates from Bluetooth
        bluetoothManager.$currentHeartRate
            .sink { [weak self] bpm in
                guard let self = self else { return }
                if self.shouldUseBluetoothData() {
                    self.handleHeartRateUpdate(bpm, from: .bluetooth)
                }
            }
            .store(in: &cancellables)

        // Observe heart rate updates from HealthKit
        healthKitManager.$currentHeartRate
            .sink { [weak self] bpm in
                guard let self = self else { return }
                if self.shouldUseHealthKitData() {
                    self.handleHeartRateUpdate(bpm, from: .appleWatch)
                }
            }
            .store(in: &cancellables)

        // Observe Bluetooth state changes
        bluetoothManager.$bluetoothState
            .sink { [weak self] state in
                self?.bluetoothState = state
                self?.updateActiveSource()
            }
            .store(in: &cancellables)

        // Observe HealthKit authorization
        healthKitManager.$isAuthorized
            .sink { [weak self] _ in
                self?.updateActiveSource()
            }
            .store(in: &cancellables)

        // Observe last update time (from both sources)
        Publishers.Merge(
            bluetoothManager.$lastUpdate,
            healthKitManager.$lastUpdate
        )
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
                self.updateStaleStatus()
            }
            .store(in: &cancellables)
    }

    private func shouldUseBluetoothData() -> Bool {
        switch dataSource {
        case .bluetooth:
            return true
        case .appleWatch:
            return false
        case .automatic:
            // Prefer Bluetooth if connected, otherwise HealthKit
            return bluetoothManager.isConnected
        }
    }

    private func shouldUseHealthKitData() -> Bool {
        switch dataSource {
        case .bluetooth:
            return false
        case .appleWatch:
            return true
        case .automatic:
            // Use HealthKit if Bluetooth not connected
            return !bluetoothManager.isConnected && healthKitManager.isAuthorized
        }
    }

    private func updateActiveSource() {
        if bluetoothManager.isConnected && shouldUseBluetoothData() {
            activeSource = .bluetooth
        } else if healthKitManager.isAuthorized && shouldUseHealthKitData() {
            activeSource = .appleWatch
        } else {
            activeSource = nil
        }
    }

    private func updateStaleStatus() {
        if activeSource == .bluetooth {
            self.isStale = self.bluetoothManager.isStale
        } else if activeSource == .appleWatch {
            // HealthKit data is considered stale if no update in 60 seconds
            if let lastUpdate = healthKitManager.lastUpdate {
                self.isStale = Date().timeIntervalSince(lastUpdate) > 60
            } else {
                self.isStale = true
            }
        } else {
            self.isStale = false
        }
    }

    private func handleDataSourceChange() {
        // Stop current sources
        bluetoothManager.stopMonitoring()
        healthKitManager.stopMonitoring()

        // Start appropriate source
        startMonitoring()
    }

    // MARK: - Public Methods

    func startMonitoring() {
        switch dataSource {
        case .bluetooth:
            bluetoothManager.startMonitoring()
        case .appleWatch:
            if healthKitManager.isAuthorized {
                healthKitManager.startMonitoring()
            } else {
                Task {
                    try? await healthKitManager.requestAuthorization()
                    if healthKitManager.isAuthorized {
                        healthKitManager.startMonitoring()
                    }
                }
            }
        case .automatic:
            // Start both, let shouldUse* methods decide which data to use
            bluetoothManager.startMonitoring()
            if healthKitManager.isAuthorized {
                healthKitManager.startMonitoring()
            } else {
                Task {
                    try? await healthKitManager.requestAuthorization()
                    if healthKitManager.isAuthorized {
                        healthKitManager.startMonitoring()
                    }
                }
            }
        }
        updateActiveSource()
    }

    func stopMonitoring() {
        bluetoothManager.stopMonitoring()
        healthKitManager.stopMonitoring()
        activeSource = nil
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

    private func handleHeartRateUpdate(_ bpm: Double, from source: HeartRateDataSource) {
        self.currentHeartRate = bpm
        self.activeSource = source

        // Update session statistics
        sessionStatistics.addSample(bpm)

        // Check alerts
        alertManager.checkHeartRate(
            bpm,
            isStale: isStale,
            hasGracePeriod: !hasGracePeriodExpired
        )

        // Update stale status
        updateStaleStatus()
    }

    // MARK: - HealthKit Authorization

    func requestHealthKitAuthorization() async throws {
        try await healthKitManager.requestAuthorization()
        if healthKitManager.isAuthorized && dataSource != .bluetooth {
            healthKitManager.startMonitoring()
            updateActiveSource()
        }
    }
}
