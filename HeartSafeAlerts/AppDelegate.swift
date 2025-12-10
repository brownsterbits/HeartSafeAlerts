import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set up notification delegate FIRST
        UNUserNotificationCenter.current().delegate = self
        
        // REQUEST NOTIFICATION PERMISSIONS IMMEDIATELY
        requestNotificationPermissions()
        
        // Define notification actions and categories
        setupNotificationCategories()
        
        return true
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                }
                if let error = error {
                    print("❌ Notification permission error: \(error)")
                }
            }
        }
    }
    
    private func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: Constants.viewActionIdentifier,
            title: "View Heart Rate",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: Constants.notificationCategoryIdentifier,
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // Handle notification tap when app is closed/background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📱 Notification tapped: \(response.actionIdentifier)")
        completionHandler()
    }
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
