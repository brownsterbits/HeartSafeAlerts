import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var monitor: HeartRateMonitor
    @AppStorage(Constants.backgroundNotificationsEnabledKey) private var backgroundNotificationsEnabled = false
    @Environment(\.dismiss) var dismiss
    
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

                Section(header: Text("Data Source")) {
                    Picker("Heart Rate Source", selection: $monitor.dataSource) {
                        ForEach(HeartRateDataSource.allCases) { source in
                            HStack {
                                Image(systemName: source.icon)
                                Text(source.rawValue)
                            }
                            .tag(source)
                        }
                    }
                    .pickerStyle(.menu)

                    if let activeSource = monitor.activeSource {
                        HStack {
                            Text("Active Source")
                            Spacer()
                            HStack {
                                Image(systemName: activeSource.icon)
                                    .foregroundColor(.green)
                                Text(activeSource.rawValue)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Text(monitor.dataSource.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Alerts")) {
                    Toggle("Enable Alerts", isOn: $monitor.alertsEnabled)
                        .accessibilityLabel("Enable heart rate alerts")

                    // Show sub-options only when main alerts are enabled
                    if monitor.alertsEnabled {
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

                Section {
                    CareCirclePreviewView()
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
