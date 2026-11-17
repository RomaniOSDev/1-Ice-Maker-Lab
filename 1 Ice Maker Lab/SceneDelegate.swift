import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = IntegrationBootstrap.makeRoot {
            UIHostingController(rootView: ContentView())
        }
        window.makeKeyAndVisible()
        self.window = window

        if let response = connectionOptions.notificationResponse {
            let userInfo = response.notification.request.content.userInfo
            if let url = PushNotificationURLRouter.shared.extractURL(from: userInfo) {
                PushNotificationURLRouter.shared.setPendingURL(url)
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let url = PushNotificationURLRouter.shared.consumePendingURL() else { return }
        // Keep pending for OfferWebView.viewDidAppear if Black UI is not up yet.
        PushNotificationURLRouter.shared.setPendingURL(url)
        NotificationCenter.default.post(name: .integrationOpenOfferURL, object: url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
