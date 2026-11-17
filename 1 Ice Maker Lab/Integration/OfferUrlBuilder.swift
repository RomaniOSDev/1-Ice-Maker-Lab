import Foundation

enum OfferUrlBuilder {

    /// Builds campaign click URL by string concatenation (not URLComponents).
    static func build(
        baseURL: String,
        routing: String,
        storage: IntegrationStorage
    ) -> String? {
        guard let parts = splitBase(baseURL) else { return nil }

        var params: [(String, String)] = []
        var seen = Set<String>()

        func append(_ key: String, _ value: String?) {
            guard let value else { return }
            // Empty idfa is allowed as empty value per TZ; skip other empties except idfa.
            if key != "idfa", value.isEmpty { return }
            if seen.contains(key) {
                if let idx = params.firstIndex(where: { $0.0 == key }) {
                    params[idx] = (key, value)
                }
            } else {
                seen.insert(key)
                params.append((key, value))
            }
        }

        // 1) Attribution fields as stored (arrival order preserved in storage merge map — Dictionary order is insertion in Swift).
        for (key, value) in storage.attributionFields {
            append(key, value)
        }

        // 2) Parsed sub1…subN override same keys
        let campaign = storage.attributionFields["campaign"]
        for item in CampaignParser.subParameters(fromCampaign: campaign) {
            append(item.key, item.value)
        }

        // 3) Device signals override sub12–14
        append("sub12", storage.sub12)
        append("sub13", storage.sub13)
        append("sub14", storage.sub14)

        // 4) Push
        append("push_token", storage.pushToken)
        append("push_id", storage.pushId)

        // Identifiers except adid
        append("idfv", storage.idfv)
        append("idfa", storage.idfa ?? "")

        // 5) adid last
        append("adid", storage.adid)

        var path = parts.path
        if routing == "prily" {
            let sub1 = params.first(where: { $0.0 == "sub1" })?.1
            if let sub1, !sub1.isEmpty {
                if path.hasSuffix("/") {
                    path += PercentEncoder.encode(sub1)
                } else {
                    path += "/" + PercentEncoder.encode(sub1)
                }
            }
        }

        var queryPieces: [String] = []
        if let existing = parts.existingQuery, !existing.isEmpty {
            queryPieces.append(existing)
        }
        for (key, value) in params {
            let k = PercentEncoder.encode(key)
            let v = PercentEncoder.encode(value)
            queryPieces.append("\(k)=\(v)")
        }

        var url = parts.schemeHost + path
        if !queryPieces.isEmpty {
            url += "?" + queryPieces.joined(separator: "&")
        }
        if let fragment = parts.fragment, !fragment.isEmpty {
            url += "#" + fragment
        }
        return url
    }

    // MARK: - Base split (no decoding)

    private struct BaseParts {
        var schemeHost: String
        var path: String
        var existingQuery: String?
        var fragment: String?
    }

    private static func splitBase(_ raw: String) -> BaseParts? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var working = trimmed
        var fragment: String?
        if let hash = working.firstIndex(of: "#") {
            fragment = String(working[working.index(after: hash)...])
            working = String(working[..<hash])
        }

        var existingQuery: String?
        if let q = working.firstIndex(of: "?") {
            existingQuery = String(working[working.index(after: q)...])
            working = String(working[..<q])
        }

        // scheme://host/path
        guard let schemeRange = working.range(of: "://") else { return nil }
        let afterScheme = working[schemeRange.upperBound...]
        let pathStart: String.Index
        if let slash = afterScheme.firstIndex(of: "/") {
            pathStart = slash
        } else {
            return BaseParts(
                schemeHost: working,
                path: "",
                existingQuery: existingQuery,
                fragment: fragment
            )
        }

        let schemeHost = String(working[..<pathStart])
        let path = String(working[pathStart...])
        return BaseParts(schemeHost: schemeHost, path: path, existingQuery: existingQuery, fragment: fragment)
    }
}
