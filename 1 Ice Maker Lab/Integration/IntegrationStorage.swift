import Foundation

/// Persistent Integration state for Adjust identifiers and push. Excluded from iCloud backup.
final class IntegrationStorage: @unchecked Sendable {

    static let shared = IntegrationStorage()

    private let queue = DispatchQueue(label: "integration.storage", qos: .userInitiated)
    private var state: State
    private let fileURL: URL

    private struct State: Codable {
        var attribution: [String: String] = [:]
        var adid: String?
        var idfv: String?
        var idfa: String?
        var pushToken: String?
        var pushId: String?
    }

    private init() {
        let dir = Self.storageDirectory()
        fileURL = dir.appendingPathComponent("integration_state.json")
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(State.self, from: data) {
            state = decoded
        } else {
            state = State()
            persistLocked()
        }
        excludeFromBackup(fileURL)
        excludeFromBackup(dir)
    }

    // MARK: - Attribution merge

    var attributionFields: [String: String] {
        queue.sync { state.attribution }
    }

    /// Merge non-empty values; never erase existing keys with empty/nil.
    func mergeAttribution(_ fields: [String: String]) {
        queue.sync {
            for (key, value) in fields {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                state.attribution[key] = trimmed
            }
            persistLocked()
        }
    }

    // MARK: - Identifiers

    var adid: String? { queue.sync { state.adid } }
    var idfv: String? { queue.sync { state.idfv } }
    var idfa: String? { queue.sync { state.idfa } }

    func setAdid(_ value: String?) {
        queue.sync {
            if let value, !value.isEmpty { state.adid = value }
            persistLocked()
        }
    }

    func setIdfv(_ value: String?) {
        queue.sync {
            if let value, !value.isEmpty { state.idfv = value.uppercased() }
            persistLocked()
        }
    }

    func setIdfa(_ value: String?) {
        queue.sync {
            guard let value, !value.isEmpty else { return }
            let zero = "00000000-0000-0000-0000-000000000000"
            if value.caseInsensitiveCompare(zero) == .orderedSame {
                state.idfa = ""
            } else {
                state.idfa = value
            }
            persistLocked()
        }
    }

    // MARK: - Push

    var pushToken: String? { queue.sync { state.pushToken } }
    var pushId: String {
        queue.sync {
            if let existing = state.pushId, !existing.isEmpty {
                return existing
            }
            let generated = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
            state.pushId = generated
            persistLocked()
            return generated
        }
    }

    func setPushTokenHex(_ hex: String) {
        queue.sync {
            guard !hex.isEmpty else { return }
            state.pushToken = hex
            persistLocked()
        }
    }

    // MARK: - Persistence

    private func persistLocked() {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: fileURL, options: [.atomic])
            excludeFromBackup(fileURL)
        } catch {
            // Best-effort persistence.
        }
    }

    private static func storageDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent("Integration", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func excludeFromBackup(_ url: URL) {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutable = url
        try? mutable.setResourceValues(values)
    }
}
