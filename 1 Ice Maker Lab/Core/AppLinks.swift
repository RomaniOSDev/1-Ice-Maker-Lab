//
//  AppLinks.swift
//  1 Ice Maker Lab
//
//  Created by Roman on 10/28/26.
//

import Foundation

enum AppLinks {
    /// Replace with App Store product URL (or `...?action=write-review`).
    static let rateApp = "https://apps.apple.com/app/id6830158784"

    /// Replace with your Privacy Policy URL.
    static let privacyPolicy = "https://www.termsfeed.com/live/57a00a9b-6b61-49dc-933d-ddbb860ee4b2"

    /// Replace with your Terms of Use URL.
    static let termsOfUse = "https://www.termsfeed.com/live/0f6db086-a781-4065-9189-483e1688656a"

    static var rateAppURL: URL { URL(string: rateApp)! }
    static var privacyPolicyURL: URL { URL(string: privacyPolicy)! }
    static var termsOfUseURL: URL { URL(string: termsOfUse)! }
}
