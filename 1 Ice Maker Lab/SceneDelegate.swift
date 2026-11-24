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
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
