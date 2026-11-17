import UIKit
import WebKit
import UniformTypeIdentifiers

protocol OfferWebViewControllerDelegate: AnyObject {
    func offerWebViewDidLockWhite(_ controller: OfferWebViewController)
    func offerWebView(_ controller: OfferWebViewController, didCacheURL url: URL)
    func offerWebViewDidFailNetwork(_ controller: OfferWebViewController)
}

final class OfferWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKDownloadDelegate, UIDocumentPickerDelegate {

    weak var delegate: OfferWebViewControllerDelegate?

    private let initialURL: URL
    private var webView: WKWebView!
    private var sessionVerdictLocked = false
    private var didCacheThisSession = false
    private var fileUploadCompletion: (([URL]?) -> Void)?
    private var openURLObserver: NSObjectProtocol?

    init(url: URL) {
        self.initialURL = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    deinit {
        if let openURLObserver {
            NotificationCenter.default.removeObserver(openURLObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureWebView()
        webView.load(URLRequest(url: initialURL))

        openURLObserver = NotificationCenter.default.addObserver(
            forName: .integrationOpenOfferURL,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let url = note.object as? URL else { return }
            self?.webView.load(URLRequest(url: url))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let pending = PushNotificationURLRouter.shared.consumePendingURL() {
            webView.load(URLRequest(url: pending))
        }
    }

    func loadOfferURL(_ url: URL) {
        webView?.load(URLRequest(url: url))
    }

    private func configureWebView() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.allowsBackForwardNavigationGestures = true
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(wv)
        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: view.topAnchor),
            wv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        webView = wv
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        if !sessionVerdictLocked,
           navigationResponse.isForMainFrame,
           let http = navigationResponse.response as? HTTPURLResponse,
           http.statusCode == 404 {
            sessionVerdictLocked = true
            delegate?.offerWebViewDidLockWhite(self)
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !didCacheThisSession else { return }
        guard let url = webView.url else { return }
        let absolute = url.absoluteString
        guard absolute != "about:blank", !absolute.isEmpty else { return }
        didCacheThisSession = true
        delegate?.offerWebView(self, didCacheURL: url)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    private func handleNavigationError(_ error: Error) {
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain, ns.code == NSURLErrorCancelled { return }
        // Network / TLS / DNS — show white temporarily without locking (handled by routing host).
        if ns.domain == NSURLErrorDomain {
            delegate?.offerWebViewDidFailNetwork(self)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        let scheme = (url.scheme ?? "").lowercased()
        if scheme == "http" || scheme == "https" || scheme == "about" || scheme.isEmpty {
            decisionHandler(.allow)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }

    func webView(
        _ webView: WKWebView,
        navigationAction: WKNavigationAction,
        didBecome download: WKDownload
    ) {
        download.delegate = self
    }

    // MARK: - WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    @available(iOS 18.4, *)
    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping ([URL]?) -> Void
    ) {
        presentFilePicker(completionHandler)
    }

    private func presentFilePicker(_ completion: @escaping ([URL]?) -> Void) {
        fileUploadCompletion = completion
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = true
        present(picker, animated: true)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        fileUploadCompletion?(nil)
        fileUploadCompletion = nil
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        fileUploadCompletion?(urls)
        fileUploadCompletion = nil
    }

    // MARK: - WKDownloadDelegate

    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        let scheme = (response.url?.scheme ?? "").lowercased()
        guard scheme == "http" || scheme == "https" else {
            completionHandler(nil)
            return
        }
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFilename)
        completionHandler(tmp)
    }

    func downloadDidFinish(_ download: WKDownload) {
        // Downloads land in temp; system share is optional — no-op is fine.
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {}
}
