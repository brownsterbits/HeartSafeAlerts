import SwiftUI

struct SessionStatsView: View {
    @ObservedObject var stats: SessionStatistics

    var body: some View {
        if stats.hasData {
            VStack(spacing: 12) {
                Text("Session Statistics")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    StatItem(label: "Min", value: "\(Int(stats.minHeartRate))", unit: "BPM")
                    StatItem(label: "Avg", value: "\(Int(stats.avgHeartRate))", unit: "BPM")
                    StatItem(label: "Max", value: "\(Int(stats.maxHeartRate))", unit: "BPM")
                }

                if stats.timeInRange > 0 || stats.timeOutOfRange > 0 {
                    Divider()
                        .padding(.vertical, 4)

                    HStack(spacing: 20) {
                        TimeStatItem(
                            label: "In Range",
                            value: stats.formattedTimeInRange(),
                            color: .green
                        )
                        TimeStatItem(
                            label: "Out of Range",
                            value: stats.formattedTimeOutOfRange(),
                            color: .red
                        )
                    }
                }

                if stats.sessionStart != nil {
                    Text("Session: \(stats.formattedDuration())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct TimeStatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(color)
        }
    }
}

#Preview {
    let stats = SessionStatistics()
    stats.addSample(75)
    stats.addSample(82)
    stats.addSample(91)
    stats.addSample(68)

    return SessionStatsView(stats: stats)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let stats = SessionStatistics()
    stats.addSample(75)
    stats.addSample(82)
    stats.addSample(91)
    stats.addSample(68)

    return SessionStatsView(stats: stats)
        .preferredColorScheme(.dark)
}
