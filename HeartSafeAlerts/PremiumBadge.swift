import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption)
            Text("PRO")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }
}

struct LockedFeatureOverlay: View {
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.15))
            
            // Lock icon and text
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Pro Feature")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("Tap to unlock")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 4)
            )
        }
        .onTapGesture(perform: onTap)
    }
}
