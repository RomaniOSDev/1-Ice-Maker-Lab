import SwiftUI
import WebKit

struct LegalPage: Identifiable {
    let title: String
    let url: URL
    var id: String { url.absoluteString }
}

/// Dismissible sheet that shows a legal page in WKWebView.
struct LegalWebSheet: View {
    let page: LegalPage
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                LegalWebRepresentable(url: page.url, isLoading: $isLoading)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading {
                    ProgressView()
                        .tint(LabColor.glacier)
                        .padding(16)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .background(Color.white)
            .navigationTitle(page.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .font(LabFont.button(15))
                        .foregroundStyle(LabColor.glacier)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}

private struct LegalWebRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}
