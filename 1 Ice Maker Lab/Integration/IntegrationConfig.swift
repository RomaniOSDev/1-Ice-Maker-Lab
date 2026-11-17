import Foundation

struct IntegrationConfig: Equatable {
    var adjustAppToken: String
    var offerBaseUrl: String
    var offerRouting: String

    static let asoRouting = "aso"

    static func loadFromBundle(_ bundle: Bundle = .main) -> IntegrationConfig {
        let info = bundle.infoDictionary ?? [:]
        let token = (info["AdjustAppToken"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let base = (info["OfferBaseUrl"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let routing = (info["OfferRouting"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? Self.asoRouting
        return IntegrationConfig(
            adjustAppToken: token,
            offerBaseUrl: base,
            offerRouting: routing.isEmpty ? Self.asoRouting : routing
        )
    }

    var isOfferBaseConfigured: Bool {
        !offerBaseUrl.isEmpty
    }
}
