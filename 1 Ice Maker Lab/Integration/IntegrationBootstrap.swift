import UIKit

enum IntegrationBootstrap {

    private static var config = IntegrationConfig.loadFromBundle()

    static func start(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        config = IntegrationConfig.loadFromBundle()
        PushManager.shared.configureFirebaseIfNeeded()
        PushManager.shared.registerForRemoteNotifications(application)
        PushManager.shared.capturePushURLFromLaunchOptions(launchOptions)
        AdjustManager.shared.start(appToken: config.adjustAppToken)
        _ = IntegrationStorage.shared.pushId
    }

    static func makeRoot(makeWhiteRoot: @escaping () -> UIViewController) -> UIViewController {
        makeWhiteRoot()
    }

    static func didRegisterForRemoteNotifications(deviceToken: Data) {
        PushManager.shared.setAPNsToken(deviceToken)
    }
}
