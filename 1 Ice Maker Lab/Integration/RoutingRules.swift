import Foundation

enum IntegrationRoute {
    case white
    case whiteUnlocked
    case offer(URL)
}

enum RoutingRules {

    static func resolve(
        config: IntegrationConfig,
        storage: IntegrationStorage
    ) -> IntegrationRoute {
        if storage.isWhiteLocked {
            return .white
        }
        if let cached = storage.freshCachedOfferURL {
            return .offer(cached)
        }
        if !config.isOfferBaseConfigured {
            return .whiteUnlocked
        }
        return .offer(URL(string: "about:blank")!) // placeholder — host builds real URL async
    }

    static func needsCampaignBuild(config: IntegrationConfig, storage: IntegrationStorage) -> Bool {
        !storage.isWhiteLocked
            && storage.freshCachedOfferURL == nil
            && config.isOfferBaseConfigured
    }
}
