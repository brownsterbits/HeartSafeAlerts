// HeartAlertsApp.swift
import SwiftUI

@main
struct HeartAlertsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var monitor = HeartRateMonitor()
    @StateObject private var premiumManager = PremiumManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitor)
                .environmentObject(premiumManager)
                .preferredColorScheme(.light) // Force light mode globally
        }
    }
}
