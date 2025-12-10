import SwiftUI

struct ContentView: View {
    @EnvironmentObject var monitor: HeartRateMonitor
    @State private var showSettings = false
    @State private var showError = false
    @State private var pulseAnimation = false

    var bannerText: String {
        if !monitor.isConnected {
            return "Tap to Reconnect ↻"
        } else if !monitor.hasGracePeriodExpired {
            return "Initializing..."
        } else if monitor.isStale {
            return "No Signal"
        } else if monitor.isOutOfRange {
            return "Warning"
        } else {
            return "Connected"
        }
    }

    var bannerBackgroundColor: Color {
        if !monitor.isConnected {
            return .gray
        } else if !monitor.hasGracePeriodExpired {
            return .blue
        } else if monitor.isStale {
            return .orange
        } else if monitor.isOutOfRange {
            return .red
        } else {
            return .green
        }
    }

    var isBannerTappable: Bool {
        return !monitor.isConnected
    }

    var heartIconColor: Color {
        return monitor.isOutOfRange ? .red : .primary
    }

    var pulseScale: CGFloat {
        return pulseAnimation ? 1.1 : 1.0
    }

    var pulseAnimationEffect: Animation? {
        UIAccessibility.isReduceMotionEnabled ? nil : .easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    }

    /// Whether to display the heart rate value (vs showing "—")
    var shouldShowHeartRate: Bool {
        return !monitor.isStale && monitor.currentHeartRate > 0
    }

    /// Whether the heart should animate (has active data)
    var shouldAnimate: Bool {
        return monitor.isConnected && !monitor.isStale
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Status Banner (tappable when disconnected)
                    Button(action: {
                        if isBannerTappable {
                            monitor.refreshConnection()
                        }
                    }) {
                        Text(bannerText)
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .frame(height: geometry.size.height * 0.2)
                            .frame(maxWidth: .infinity)
                            .background(bannerBackgroundColor)
                            .padding(.top, 10)
                    }
                    .disabled(!isBannerTappable)
                    .accessibilityLabel(isBannerTappable ? "Tap to reconnect to heart rate monitor" : "Status: \(bannerText)")

                    Spacer()

                    VStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(heartIconColor)
                            .scaleEffect(pulseScale)
                            .animation(pulseAnimationEffect, value: pulseAnimation)
                            .accessibilityLabel("Heart icon")
                            .onAppear {
                                updatePulseAnimation()
                            }
                            .onChange(of: monitor.isStale) { oldValue, newValue in
                                updatePulseAnimation()
                            }
                            .onChange(of: monitor.isConnected) { oldValue, newValue in
                                updatePulseAnimation()
                            }

                        Text(shouldShowHeartRate ? String(format: "%.0f", monitor.currentHeartRate) + " BPM" : "— BPM")
                            .font(.system(size: 48, weight: .bold))
                            .accessibilityLabel("Current heart rate")

                        if monitor.isStale {
                            // Show last update when stale
                            if let last = monitor.lastUpdate {
                                Text("Last updated: \(timeAgoString(from: last))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // Show target range when connected
                            Text("Target range: \(monitor.minHeartRate)–\(monitor.maxHeartRate) BPM")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Session Statistics
                    SessionStatsView(stats: monitor.sessionStatistics)
                        .padding(.top, 20)

                    Spacer()

                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .padding()
                            .accessibilityLabel("Settings")
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
        }
    }

    private func updatePulseAnimation() {
        withAnimation {
            pulseAnimation = shouldAnimate && !UIAccessibility.isReduceMotionEnabled
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case 0..<60:
            return "\(seconds)s ago"
        case 60..<3600:
            return "\(seconds / 60)m ago"
        case 3600..<86400:
            return "\(seconds / 3600)h ago"
        default:
            return ">24h ago"
        }
    }
}
