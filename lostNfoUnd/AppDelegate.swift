//
//  AppDelegate.swift
//  lostNfoUnd
//
//  Created by Neel Chandwani on 12/4/24.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        print("Firebase configured successfully!")

        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        
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

   
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(fcmToken ?? "No token")")
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let message = userInfo["body"] as? String {
            NotificationCenter.default.post(name: NSNotification.Name("NotificationReceived"), object: nil, userInfo: ["message": message])
        }
        completionHandler()
    }
}
