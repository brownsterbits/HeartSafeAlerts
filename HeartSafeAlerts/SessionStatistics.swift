import Foundation

/// Tracks heart rate statistics for the current monitoring session
@MainActor
class SessionStatistics: ObservableObject {
    // MARK: - Published Properties

    @Published var minHeartRate: Double = 0
    @Published var maxHeartRate: Double = 0
    @Published var avgHeartRate: Double = 0
    @Published var timeInRange: TimeInterval = 0
    @Published var timeOutOfRange: TimeInterval = 0
    @Published var sessionStart: Date?
    @Published var sampleCount: Int = 0

    // MARK: - Private Properties

    private var samples: [HeartRateSample] = []
    private var lastSampleTime: Date?
    private var minThreshold: Int = 0
    private var maxThreshold: Int = 0

    // MARK: - Types

    private struct HeartRateSample {
        let bpm: Double
        let timestamp: Date
        let inRange: Bool
    }

    // MARK: - Public Methods

    /// Start a new session
    func startSession(minThreshold: Int, maxThreshold: Int) {
        self.minThreshold = minThreshold
        self.maxThreshold = maxThreshold
        sessionStart = Date()
        reset()
    }

    /// Add a new heart rate sample
    func addSample(_ bpm: Double) {
        let now = Date()
        let inRange = bpm >= Double(minThreshold) && bpm <= Double(maxThreshold)

        let sample = HeartRateSample(bpm: bpm, timestamp: now, inRange: inRange)
        samples.append(sample)
        sampleCount = samples.count

        // Update min/max
        if minHeartRate == 0 || bpm < minHeartRate {
            minHeartRate = bpm
        }
        if bpm > maxHeartRate {
            maxHeartRate = bpm
        }

        // Update average
        avgHeartRate = samples.map { $0.bpm }.reduce(0, +) / Double(samples.count)

        // Update time in/out of range
        if let lastTime = lastSampleTime {
            let elapsed = now.timeIntervalSince(lastTime)
            if inRange {
                timeInRange += elapsed
            } else {
                timeOutOfRange += elapsed
            }
        }

        lastSampleTime = now
    }

    /// Reset all statistics
    func reset() {
        samples.removeAll()
        minHeartRate = 0
        maxHeartRate = 0
        avgHeartRate = 0
        timeInRange = 0
        timeOutOfRange = 0
        sampleCount = 0
        lastSampleTime = nil
    }

    /// Update thresholds (if user changes them mid-session)
    func updateThresholds(min: Int, max: Int) {
        self.minThreshold = min
        self.maxThreshold = max
        recalculateRangeTimes()
    }

    // MARK: - Computed Properties

    var sessionDuration: TimeInterval {
        guard let start = sessionStart else { return 0 }
        return Date().timeIntervalSince(start)
    }

    var hasData: Bool {
        return !samples.isEmpty
    }

    var percentInRange: Double {
        let total = timeInRange + timeOutOfRange
        guard total > 0 else { return 0 }
        return (timeInRange / total) * 100
    }

    // MARK: - Private Methods

    private func recalculateRangeTimes() {
        timeInRange = 0
        timeOutOfRange = 0

        for i in 0..<samples.count {
            let sample = samples[i]
            let inRange = sample.bpm >= Double(minThreshold) && sample.bpm <= Double(maxThreshold)

            if i > 0 {
                let elapsed = sample.timestamp.timeIntervalSince(samples[i-1].timestamp)
                if inRange {
                    timeInRange += elapsed
                } else {
                    timeOutOfRange += elapsed
                }
            }

            // Update the sample's inRange status
            samples[i] = HeartRateSample(bpm: sample.bpm, timestamp: sample.timestamp, inRange: inRange)
        }
    }

    // MARK: - Formatted Strings

    func formattedDuration() -> String {
        let duration = sessionDuration
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    func formattedTimeInRange() -> String {
        return formatTimeInterval(timeInRange)
    }

    func formattedTimeOutOfRange() -> String {
        return formatTimeInterval(timeOutOfRange)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}
