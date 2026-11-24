import Foundation

struct IntegrationConfig: Equatable {
    var adjustAppToken: String

    static func loadFromBundle(_ bundle: Bundle = .main) -> IntegrationConfig {
        let info = bundle.infoDictionary ?? [:]
        let token = (info["AdjustAppToken"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return IntegrationConfig(adjustAppToken: token)
    }
}
