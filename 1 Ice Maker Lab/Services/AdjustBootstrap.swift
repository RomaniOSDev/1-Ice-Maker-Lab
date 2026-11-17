//
//  AdjustBootstrap.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 11/16/26.
//

import Foundation
import AdjustSdk

enum AdjustBootstrap {

    /// Replace with your Adjust app token from the Adjust dashboard.
    static let appToken = "YOUR_ADJUST_APP_TOKEN"

    static func start() {
        #if DEBUG
        let environment = ADJEnvironmentSandbox
        let logLevel = ADJLogLevel.verbose
        #else
        let environment = ADJEnvironmentProduction
        let logLevel = ADJLogLevel.suppress
        #endif

        guard let config = ADJConfig(
            appToken: appToken,
            environment: environment
        ) else {
            return
        }

        config.logLevel = logLevel
        Adjust.initSdk(config)
    }
}
