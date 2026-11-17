import UIKit

/// Top-level switch: White (native) vs Black (Offer WebView).
final class IntegrationRootViewController: UIViewController, OfferWebViewControllerDelegate {

    private let config: IntegrationConfig
    private let storage = IntegrationStorage.shared
    private let makeWhiteRoot: () -> UIViewController
    private var child: UIViewController?
    private var building = false

    init(config: IntegrationConfig, makeWhiteRoot: @escaping () -> UIViewController) {
        self.config = config
        self.makeWhiteRoot = makeWhiteRoot
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        resolveAndPresent()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func resolveAndPresent() {
        if storage.isWhiteLocked {
            presentWhite()
            return
        }
        if let cached = storage.freshCachedOfferURL {
            presentOffer(url: cached)
            return
        }
        if !config.isOfferBaseConfigured {
            presentWhite()
            return
        }
        buildCampaignAndPresent()
    }

    private func buildCampaignAndPresent() {
        guard !building else { return }
        building = true
        showLoading()

        Task { @MainActor in
            await Task.detached(priority: .userInitiated) {
                DeviceSignals.captureIfNeeded(into: IntegrationStorage.shared)
            }.value

            async let attribution: Void = AdjustManager.shared.waitForAttribution(timeoutSeconds: 8)
            async let ids: Void = AdjustManager.shared.ensureIdentifiersSettled(timeoutSeconds: 8)
            async let token = PushManager.shared.waitForToken(timeoutSeconds: 2.5)
            _ = await (attribution, ids, token)

            guard let raw = OfferUrlBuilder.build(
                baseURL: config.offerBaseUrl,
                routing: config.offerRouting,
                storage: storage
            ), let url = URL(string: raw) else {
                building = false
                presentWhite()
                return
            }

            if storage.adid == nil || storage.adid?.isEmpty == true {
                print("[Integration] WARNING: adid is empty — Adjust session not received (DNS/network). URL still opens.")
            }

            building = false
            presentOffer(url: url)
        }
    }

    private func showLoading() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func presentWhite() {
        embed(makeWhiteRoot())
    }

    private func presentOffer(url: URL) {
        print("[Integration] final offer URL: \(url.absoluteString)")
        let offer = OfferWebViewController(url: url)
        offer.delegate = self
        embed(offer)
    }

    private func embed(_ controller: UIViewController) {
        if let child {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        child = controller
    }

    // MARK: - OfferWebViewControllerDelegate

    func offerWebViewDidLockWhite(_ controller: OfferWebViewController) {
        storage.lockWhiteForever()
        presentWhite()
    }

    func offerWebView(_ controller: OfferWebViewController, didCacheURL url: URL) {
        storage.cacheOfferURL(url)
    }

    func offerWebViewDidFailNetwork(_ controller: OfferWebViewController) {
        // Do not lock White — temporary native shell.
        presentWhite()
    }
}
