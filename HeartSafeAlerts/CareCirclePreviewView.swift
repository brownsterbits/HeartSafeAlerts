import SwiftUI

struct CareCirclePreviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Care Circle")
                    .font(.headline)
                Spacer()
                Text("COMING SOON")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
            }

            Text("Keep your loved ones in the loop. Automatically alert your trusted contacts when your heart rate is outside your target range.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "bell.badge.fill", text: "Alert escalation to your circle")
                FeatureRow(icon: "checkmark.circle.fill", text: "Check-in workflow (\"I'm okay\")")
                FeatureRow(icon: "doc.text.fill", text: "Weekly health summaries")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Historical data and trends")
            }
            .padding(.vertical, 8)

            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text("Premium Feature")
                    .font(.caption.bold())
                Spacer()
                Text("$2.99/month")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    CareCirclePreviewView()
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CareCirclePreviewView()
        .padding()
        .preferredColorScheme(.dark)
}
