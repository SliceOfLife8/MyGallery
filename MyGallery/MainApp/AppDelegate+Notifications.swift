//
//  AppDelegate+Notifications.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 15/11/21.
//

import FirebaseMessaging

// MARK: - NotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func setupNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void) {
        process(notification)
        completionHandler([[.banner, .sound]])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        process(response.notification)
        completionHandler()
    }

    private func process(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        /// With Firebase Analytics and Cloud Messaging, you can track the events surrounding your notifications.
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}

extension AppDelegate: MessagingDelegate {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: .fcmToken,
            object: nil,
            userInfo: tokenDict)
    }
}
