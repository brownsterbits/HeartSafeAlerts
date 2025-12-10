import Foundation
import HealthKit

/// Manages HealthKit integration for reading heart rate from Apple Watch or iPhone
@MainActor
class HealthKitManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var currentHeartRate: Double = 0
    @Published var lastUpdate: Date?
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var lastError: Error?

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var isMonitoring = false

    // MARK: - Computed Properties

    var isAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    var hasData: Bool {
        return lastUpdate != nil
    }

    // MARK: - Authorization

    /// Request HealthKit authorization for heart rate reading
    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.heartRateTypeNotAvailable
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [heartRateType])

            // Check the actual authorization status
            let status = healthStore.authorizationStatus(for: heartRateType)
            await MainActor.run {
                self.authorizationStatus = status
                self.isAuthorized = (status == .sharingAuthorized)
            }
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            throw error
        }
    }

    /// Check current authorization status without requesting
    func checkAuthorizationStatus() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let status = healthStore.authorizationStatus(for: heartRateType)
        self.authorizationStatus = status
        self.isAuthorized = (status == .sharingAuthorized)
    }

    // MARK: - Monitoring

    /// Start continuous heart rate monitoring
    func startMonitoring() {
        guard isAvailable && isAuthorized else {
            lastError = HealthKitError.notAuthorized
            return
        }

        // Always stop existing monitoring before starting new to prevent query leaks
        stopMonitoring()

        guard !isMonitoring else { return }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            lastError = HealthKitError.heartRateTypeNotAvailable
            return
        }

        isMonitoring = true

        // Create an anchored object query for continuous updates
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            Task { @MainActor in
                self?.handleHeartRateSamples(samples: samples, error: error)
            }
        }

        // Set update handler for continuous monitoring
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            Task { @MainActor in
                self?.handleHeartRateSamples(samples: samples, error: error)
            }
        }

        heartRateQuery = query
        healthStore.execute(query)
    }

    /// Stop heart rate monitoring
    func stopMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        isMonitoring = false
    }

    // MARK: - Private Methods

    private func handleHeartRateSamples(samples: [HKSample]?, error: Error?) {
        if let error = error {
            Task { @MainActor in
                self.lastError = error
            }
            return
        }

        guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
            return
        }

        // Get the most recent sample
        guard let mostRecent = samples.sorted(by: { $0.endDate > $1.endDate }).first else {
            return
        }

        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let bpm = mostRecent.quantity.doubleValue(for: bpmUnit)

        Task { @MainActor in
            self.currentHeartRate = bpm
            self.lastUpdate = mostRecent.endDate
        }
    }

    /// Fetch the most recent heart rate sample (one-time fetch)
    func fetchLatestHeartRate() async throws -> Double? {
        guard isAvailable && isAuthorized else {
            throw HealthKitError.notAuthorized
        }

        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            throw HealthKitError.heartRateTypeNotAvailable
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                let bpmUnit = HKUnit.count().unitDivided(by: .minute())
                let bpm = sample.quantity.doubleValue(for: bpmUnit)

                Task { @MainActor in
                    self.currentHeartRate = bpm
                    self.lastUpdate = sample.endDate
                }

                continuation.resume(returning: bpm)
            }

            healthStore.execute(query)
        }
    }
}

// MARK: - Error Types

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case heartRateTypeNotAvailable
    case noDataAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device."
        case .notAuthorized:
            return "HealthKit access not authorized. Please grant permission in Settings."
        case .heartRateTypeNotAvailable:
            return "Heart rate data type is not available."
        case .noDataAvailable:
            return "No heart rate data available from HealthKit."
        }
    }
}
