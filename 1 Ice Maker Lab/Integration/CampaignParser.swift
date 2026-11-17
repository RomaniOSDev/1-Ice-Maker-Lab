import Foundation

enum CampaignParser {

    /// Splits raw campaign by `_` into `sub1…subN`.
    static func subParameters(fromCampaign campaign: String?) -> [(key: String, value: String)] {
        guard let campaign, !campaign.isEmpty else { return [] }
        let parts = campaign.split(separator: "_", omittingEmptySubsequences: false).map(String.init)
        return parts.enumerated().map { index, value in
            (key: "sub\(index + 1)", value: value)
        }
    }
}
