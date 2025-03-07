//
//  AppDelegate.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 3/4/25.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        print("Firebase configured successfully!")

        // Set up FCM (Firebase Cloud Messaging)
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }

        application.registerForRemoteNotifications()
        return true
    }

    // Handle FCM token updates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(fcmToken ?? "No token")")
        // Send the FCM token to your server if needed
    }

    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    // Handle notifications when the app is in the background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let message = userInfo["body"] as? String {
            // Pass the notification content to ContentView
            NotificationCenter.default.post(name: NSNotification.Name("NotificationReceived"), object: nil, userInfo: ["message": message])
        }
        completionHandler()
    }
}
