import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var monitor: HeartRateMonitor
    @EnvironmentObject var premiumManager: PremiumManager
    @AppStorage(Constants.backgroundNotificationsEnabledKey) private var backgroundNotificationsEnabled = false
    @Environment(\.dismiss) var dismiss
    @State private var showPremiumPaywall = false
    @State private var showRestoreSuccess = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Heart Rate Thresholds")) {
                    HStack {
                        Text("Minimum BPM")
                        Spacer()
                        Text("\(monitor.minHeartRate)")
                            .foregroundColor(.gray)
                            .accessibilityLabel("Minimum heart rate: \(monitor.minHeartRate) beats per minute")
                    }
                    Slider(
                        value: Binding(
                            get: { Double(monitor.minHeartRate) },
                            set: { monitor.minHeartRate = Int($0) }
                        ),
                        in: Double(Constants.minHeartRateLimit)...Double(Constants.defaultMaxHeartRate),
                        step: 5
                    )
                    .accessibilityLabel("Adjust minimum heart rate")
                    
                    HStack {
                        Text("Maximum BPM")
                        Spacer()
                        Text("\(monitor.maxHeartRate)")
                            .foregroundColor(.gray)
                            .accessibilityLabel("Maximum heart rate: \(monitor.maxHeartRate) beats per minute")
                    }
                    Slider(
                        value: Binding(
                            get: { Double(monitor.maxHeartRate) },
                            set: { monitor.maxHeartRate = Int($0) }
                        ),
                        in: Double(Constants.defaultMinHeartRate)...Double(Constants.maxHeartRateLimit),
                        step: 5
                    )
                    .accessibilityLabel("Adjust maximum heart rate")
                }
                
                Section(header:
                    HStack {
                        Text("Alerts")
                        if !premiumManager.isPremium {
                            PremiumBadge()
                        }
                    }
                ) {
                    ZStack {
                        VStack(spacing: 15) {
                            Toggle("Enable Alerts", isOn: $monitor.alertsEnabled)
                                .accessibilityLabel("Enable heart rate alerts")
                                .disabled(!premiumManager.isPremium)
                            
                            // Show sub-options only when main alerts are enabled
                            if monitor.alertsEnabled && premiumManager.isPremium {
                                Toggle("Sound Alerts", isOn: $monitor.soundAlertsEnabled)
                                    .accessibilityLabel("Enable sound alerts")
                                    .padding(.leading, 20)
                                
                                Toggle("Vibration Alerts", isOn: $monitor.vibrationAlertsEnabled)
                                    .accessibilityLabel("Enable vibration alerts")
                                    .padding(.leading, 20)
                                
                                Toggle("Background Notifications", isOn: $backgroundNotificationsEnabled)
                                    .accessibilityLabel("Enable background notifications")
                                    .padding(.leading, 20)
                                    .onChange(of: backgroundNotificationsEnabled) { _, newValue in
                                        if newValue {
                                            requestNotificationPermission()
                                        }
                                    }
                            }
                        }
                        
                        if !premiumManager.isPremium {
                            LockedFeatureOverlay {
                                showPremiumPaywall = true
                            }
                        }
                    }
                }
                
                Section(header: Text("Device Status")) {
                    HStack {
                        Text("Connection")
                        Spacer()
                        HStack {
                            if monitor.isConnected && monitor.isStale {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                            }
                            Text(monitor.bluetoothState.description)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if monitor.isConnected {
                        HStack {
                            Text("Current Heart Rate")
                            Spacer()
                            if monitor.isStale {
                                Text("No signal")
                                    .foregroundColor(.orange)
                            } else {
                                Text("\(Int(monitor.currentHeartRate)) BPM")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if let lastUpdate = monitor.lastUpdate {
                            HStack {
                                Text("Last Update")
                                Spacer()
                                Text(timeAgoString(from: lastUpdate))
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if premiumManager.isPremium {
                    Section(header: Text("Pro Status")) {
                        HStack {
                            Text("Status")
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("Active")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        if let purchaseDate = UserDefaults.standard.object(forKey: Constants.premiumPurchaseDateKey) as? Date {
                            HStack {
                                Text("Purchased")
                                Spacer()
                                Text(purchaseDate, style: .date)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // Simple restore purchase option for everyone
                Section {
                    Button(action: {
                        Task {
                            let wasPremiumBefore = premiumManager.isPremium
                            await premiumManager.restorePurchases()
                            
                            // Only show success if:
                            // 1. No error occurred
                            // 2. User is now premium
                            // 3. They weren't already premium (new restore)
                            if premiumManager.errorMessage == nil &&
                               premiumManager.isPremium &&
                               !wasPremiumBefore {
                                showRestoreSuccess = true
                            }
                        }
                    }) {
                        HStack {
                            Text("Restore Purchase")
                            Spacer()
                            if premiumManager.purchaseInProgress {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(premiumManager.purchaseInProgress)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Constants.fullVersionString)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Chad Brown")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showPremiumPaywall) {
            PremiumPaywallView()
        }
        .alert("Pro Restored", isPresented: $showRestoreSuccess) {
            Button("OK") { }
        } message: {
            Text("Your pro purchase has been restored successfully!")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                premiumManager.errorMessage = nil
                showError = false
            }
        } message: {
            Text(premiumManager.errorMessage ?? "Unknown error")
        }
        .onChange(of: premiumManager.errorMessage) { oldValue, newValue in
            showError = newValue != nil && !premiumManager.purchaseInProgress
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        switch seconds {
        case 0..<60:
            return "\(seconds)s ago"
        case 60..<3600:
            let minutes = seconds / 60
            return "\(minutes)m ago"
        default:
            let hours = seconds / 3600
            if hours == 1 {
                return "1h ago"
            } else if hours < 24 {
                return "\(hours)h ago"
            } else {
                return ">24h ago"
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if !granted {
                DispatchQueue.main.async {
                    backgroundNotificationsEnabled = false
                }
                
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
    }
}
