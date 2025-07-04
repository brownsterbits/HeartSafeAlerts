import SwiftUI

struct PremiumPaywallView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) var dismiss
    @State private var showRestoreAlert = false
    @State private var showThankYou = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.red.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                                .symbolRenderingMode(.hierarchical)
                            
                            Text("Upgrade to Pro")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Unlock life-saving alerts")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(
                                icon: "speaker.wave.3.fill",
                                title: "Sound Alerts",
                                description: "Instant audio warnings when your heart rate is out of range"
                            )
                            
                            FeatureRow(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Vibration Alerts",
                                description: "Feel the alert even in noisy environments"
                            )
                            
                            FeatureRow(
                                icon: "bell.badge.fill",
                                title: "Background Notifications",
                                description: "Get notified even when the app is closed"
                            )
                            
                            FeatureRow(
                                icon: "heart.text.square.fill",
                                title: "Custom Thresholds",
                                description: "Set personalized min/max heart rate limits"
                            )
                            
                            FeatureRow(
                                icon: "infinity",
                                title: "Lifetime Access",
                                description: "One-time purchase, no subscriptions"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Price and Purchase Button
                        VStack(spacing: 20) {
                            if premiumManager.isLoadingProducts {
                                ProgressView()
                                    .scaleEffect(1.2)
                            } else {
                                // Price
                                Text(premiumManager.localizedPrice)
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                // Purchase Button
                                Button(action: {
                                    Task {
                                        await premiumManager.purchase()
                                    }
                                }) {
                                    HStack {
                                        if premiumManager.purchaseInProgress {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.8)
                                        } else {
                                            Text("Get Pro Access")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                }
                                .disabled(premiumManager.purchaseInProgress || premiumManager.products.isEmpty)
                                
                                // Restore Button
                                Button(action: {
                                    Task {
                                        await premiumManager.restorePurchases()
                                    }
                                }) {
                                    Text("Restore Purchase")
                                        .foregroundColor(.red)
                                        .underline()
                                }
                                .disabled(premiumManager.purchaseInProgress)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        // Error message
                        if let error = premiumManager.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .foregroundColor(.red)
                            }
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Terms
                        VStack(spacing: 5) {
                            Text("Payment will be charged to your Apple ID account.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: premiumManager.isPremium) { _, isPremium in
            if isPremium {
                showThankYou = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        }
        .overlay(
            // Thank you banner
            Group {
                if showThankYou {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Thank you! Pro features unlocked!")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding()
                    }
                    .animation(.spring(), value: showThankYou)
                }
            }
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}
