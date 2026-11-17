import StartAppKit
import SwiftUI

extension StartAppConfiguration {

    static var app: StartAppConfiguration {
        StartAppConfiguration(
            calendarGateAnchor: StartAppSecrets.calendarGateAnchor,
            remoteEntryTemplate: StartAppSecrets.remoteFlowEntryTemplate,
            stagingMessage: "Loading...",
            // Optional: stagingBackground: Image("Start"),
            // Optional: stagingStyle: StartAppStagingStyle(progressTint: .white),
            nativeRoot: { ContentView() }
        )
    }
}
