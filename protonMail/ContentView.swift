import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebView(urlString: "https://mail.proton.me/")
            .background(
                VisualEffectView(
                    material: .sidebar,
                    blendingMode: .behindWindow
                )
            )
            .ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Color.clear.frame(width: 0, height: 0) // Invisible toolbar item!
                }
            }
    }
}

struct WebView: NSViewRepresentable {
    let urlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // CSS Injection
        let cssInjectionScript = WKUserScript(
            source: """
            (function() {
                var style = document.createElement('style');
                style.innerHTML = `
                    body {
                        background: transparent;
                    }


                    .topnav-container .topnav-list .topnav-listItem .button {
                        display: none !important;
                    }

                    /* Sidebar */
                    .content-container .content .sidebar:has(.button),
                    .content-container .content :last-child:has(.sidebar),
                    .content-container > .flex-column,
                    .content-container:has(.content .sidebar .button),
                    .flex-row,
                    div:has(#icons-root svg #ic-arrow-down-line),
                    [dir="ltr"] {
                        background: transparent !important;
                    }

                    .sidebar {
                        user-select: none;
                    }


                    /* Remove external stuff */
                    .content .sidebar .logo-container [style],
                    .dropdown-content .dropdown-item .text-sm:has(.link) {
                        display: none !important;
                    }

                    /* Content View */
                    .main {
                        --pad: 1rem;
                        margin: var(--pad) var(--pad) var(--pad) 0;
                        border-radius: 1rem
                    }
                `;
                document.head.appendChild(style);
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        userContentController.addUserScript(cssInjectionScript)
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // Configure WebView appearance
        webView.setValue(false, forKey: "drawsBackground")
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
