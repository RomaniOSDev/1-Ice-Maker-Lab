import Foundation
import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

final class PushManager: NSObject {
    static let shared = PushManager()

    private let storage = IntegrationStorage.shared
    private var tokenContinuations: [CheckedContinuation<String?, Never>] = []
    private let lock = NSLock()

    private override init() {
        super.init()
    }

    func configureFirebaseIfNeeded() {
        if FirebaseApp.app() == nil {
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: path) {
                FirebaseConfiguration.shared.setLoggerLevel(.min)
                FirebaseApp.configure(options: options)
            }
        }
        guard FirebaseApp.app() != nil else { return }
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    func setAPNsToken(_ deviceToken: Data) {
        guard FirebaseApp.app() != nil else { return }
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { [weak self] token, _ in
            self?.handleFCMToken(token)
        }
    }

    func capturePushURLFromLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
              let url = PushNotificationURLRouter.shared.extractURL(from: userInfo) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func waitForToken(timeoutSeconds: TimeInterval = 2.5) async -> String? {
        if let existing = storage.pushToken, !existing.isEmpty {
            return existing
        }
        if FirebaseApp.app() != nil, let current = Messaging.messaging().fcmToken, !current.isEmpty {
            storage.setPushTokenHex(current)
            return current
        }

        return await withCheckedContinuation { continuation in
            lock.lock()
            tokenContinuations.append(continuation)
            lock.unlock()

            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in
                guard let self else { return }
                self.resolveWaiters(self.storage.pushToken)
            }
        }
    }

    private func resolveWaiters(_ token: String?) {
        lock.lock()
        let waiters = tokenContinuations
        tokenContinuations.removeAll()
        lock.unlock()
        waiters.forEach { $0.resume(returning: token) }
    }

    private func handleFCMToken(_ token: String?) {
        guard let token, !token.isEmpty else { return }
        storage.setPushTokenHex(token)
        resolveWaiters(token)
    }
}

extension PushManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        handleFCMToken(fcmToken)
    }
}

extension PushManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let url = PushNotificationURLRouter.shared.extractURL(from: userInfo) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        completionHandler()
    }
}
