//
//  HTMLWebView.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 18/02/2025.
//

import SwiftUI
import WebKit

struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String
    @Binding var dynamicHeight: CGFloat

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body {
                        font-family: -apple-system, sans-serif;
                        font-size: 10px; /* Adjust this value as needed */
                        line-height: 1.5;
                        color: #000; /* Text color */
                        margin: 0;
                        padding: 0;
                    }
                    h1 { font-size: 24px; }
                    h2 { font-size: 22px; }
                    h3 { font-size: 20px; }
                    p { font-size: 16px; }
                </style>
            </head>
            <body>
                \(htmlContent)
            </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLWebView
        private var lastHeight: CGFloat = 0

        init(_ parent: HTMLWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { result, error in
                if let height = result as? CGFloat {

                    if abs(self.lastHeight - height) > 1 {
                        self.lastHeight = height

                        DispatchQueue.main.async {
                            self.parent.dynamicHeight = height
                        }
                    }
                }
            }
        }
    }
}
