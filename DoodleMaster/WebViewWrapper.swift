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
    @ObservedObject var taskState: TaskState
    
    init(taskState: TaskState) {
        self.taskState = taskState
    }

    func makeUIView(context: Context) -> WKWebView  {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let view = WKWebView(frame: .zero, configuration: config)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Web/task", ofType: "html")!)
        view.loadFileURL(url, allowingReadAccessTo: url)
        view.evaluateJavaScript("task=\"\(taskState.task.path)\";")
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if taskState.failing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                uiView.evaluateJavaScript("Restart();")
            }
        }
        if taskState.passing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                uiView.evaluateJavaScript("SetStep(\(self.taskState.stepNumber + 1));")
            }
        }
    }
}
