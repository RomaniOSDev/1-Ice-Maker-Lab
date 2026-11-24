import Foundation
import AdjustSdk
import UIKit

final class AdjustManager: NSObject {
    static let shared = AdjustManager()

    private let storage = IntegrationStorage.shared
    private var didStart = false
    private let attributionLock = NSLock()
    private var attributionWaiters: [CheckedContinuation<Void, Never>] = []
    private var attributionReceived = false

    private override init() {
        super.init()
    }

    func start(appToken: String) {
        guard !didStart else { return }
        didStart = true
        guard !appToken.isEmpty, appToken != "YOUR_ADJUST_APP_TOKEN" else { return }

        #if DEBUG
        let environment = ADJEnvironmentSandbox
        #else
        let environment = ADJEnvironmentProduction
        #endif

        guard let config = ADJConfig(appToken: appToken, environment: environment) else { return }
        config.logLevel = ADJLogLevel.suppress
        config.delegate = self
        Adjust.initSdk(config)

        prefetchIdentifiers()
        pollAttributionOnce()
    }

    private func prefetchIdentifiers() {
        Adjust.adid(withTimeout: 2000, completionHandler: { [weak self] adid in
            self?.storage.setAdid(adid)
        })
        Adjust.idfv(completionHandler: { [weak self] idfv in
            if let idfv, !idfv.isEmpty {
                self?.storage.setIdfv(idfv)
            } else if let vendor = UIDevice.current.identifierForVendor?.uuidString {
                self?.storage.setIdfv(vendor)
            }
        })
        Adjust.idfa(completionHandler: { [weak self] idfa in
            self?.storage.setIdfa(idfa)
        })
    }

    private func pollAttributionOnce() {
        Adjust.attribution(completionHandler: { [weak self] attribution in
            self?.ingest(attribution)
        })
    }

    func waitForAttribution(timeoutSeconds: TimeInterval = 8) async {
        if attributionReceived || !storage.attributionFields.isEmpty {
            // Still give a short window for first-session attribution if empty.
            if !storage.attributionFields.isEmpty { return }
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            attributionLock.lock()
            if attributionReceived {
                attributionLock.unlock()
                continuation.resume()
                return
            }
            attributionWaiters.append(continuation)
            attributionLock.unlock()

            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in
                self?.finishAttributionWait()
            }
        }
    }

    private func finishAttributionWait() {
        attributionLock.lock()
        let waiters = attributionWaiters
        attributionWaiters.removeAll()
        attributionLock.unlock()
        waiters.forEach { $0.resume() }
    }

    private func ingest(_ attribution: ADJAttribution?) {
        guard let attribution else { return }
        var fields: [String: String] = [:]

        if let dict = attribution.dictionary() as? [String: Any] {
            for (key, value) in dict {
                if key == "jsonResponse" {
                    if let nested = value as? [String: Any] {
                        for (nk, nv) in nested {
                            if let s = Self.stringValue(nv) {
                                fields[nk] = s
                            }
                        }
                    }
                    continue
                }
                if let s = Self.stringValue(value) {
                    fields[key] = s
                }
            }
        }

        // Named properties always merge (may duplicate keys — OK, merge keeps non-empty).
        if let v = attribution.network { fields["network"] = v }
        if let v = attribution.campaign { fields["campaign"] = v }
        if let v = attribution.adgroup { fields["adgroup"] = v }
        if let v = attribution.creative { fields["creative"] = v }
        if let v = attribution.trackerToken { fields["trackerToken"] = v }
        if let v = attribution.trackerName { fields["trackerName"] = v }
        if let v = attribution.clickLabel { fields["click_label"] = v }
        if let v = attribution.costType { fields["costType"] = v }
        if let v = attribution.costCurrency { fields["costCurrency"] = v }
        if let v = attribution.costAmount { fields["costAmount"] = v.stringValue }

        storage.mergeAttribution(fields)
        attributionLock.lock()
        attributionReceived = true
        attributionLock.unlock()
        finishAttributionWait()
    }

    private static func stringValue(_ value: Any) -> String? {
        if let s = value as? String {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            return t.isEmpty ? nil : t
        }
        if let n = value as? NSNumber {
            return n.stringValue
        }
        return nil
    }

    func ensureIdentifiersSettled(timeoutSeconds: TimeInterval = 8.0) async {
        if storage.adid != nil, storage.idfv != nil { return }

        // Keep asking Adjust while session/attribution may still be in flight.
        let timeoutMs = Int(max(1.0, timeoutSeconds) * 1000)
        Adjust.adid(withTimeout: timeoutMs, completionHandler: { [weak self] adid in
            self?.storage.setAdid(adid)
        })

        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if storage.adid != nil, storage.idfv != nil { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        if storage.idfv == nil, let vendor = UIDevice.current.identifierForVendor?.uuidString {
            storage.setIdfv(vendor)
        }
    }
}

extension AdjustManager: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        ingest(attribution)
    }
}
