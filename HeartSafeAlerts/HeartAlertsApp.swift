// HeartAlertsApp.swift
import SwiftUI

@main
struct HeartAlertsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var monitor = HeartRateMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monitor)
        }
    }
}
