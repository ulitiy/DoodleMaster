//
//  WebViewWrapper.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 12.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import WebKit

final class WebViewWrapper : UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView  {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let view = WKWebView(frame: .zero, configuration: config)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Web/task", ofType: "html")!)
        print(url)
        view.loadFileURL(url, allowingReadAccessTo: url)
        view.evaluateJavaScript("task=\"1/1/1\";")
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
