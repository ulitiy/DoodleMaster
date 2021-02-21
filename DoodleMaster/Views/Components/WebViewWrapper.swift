//
//  WebViewWrapper.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 12.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import WebKit
import MetalKit
import Combine

struct WebViewWrapper : UIViewControllerRepresentable {
    @ObservedObject var taskState: TaskState
    
    func makeUIViewController(context: Context) -> WebViewController {
        let controller = WebViewController()
        controller.taskState = taskState
        return controller
    }
    
    func updateUIViewController(_ controller: WebViewController, context: Context) {
    }
}

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var taskState: TaskState!
    var wkWebView: WKWebView!
    var skipAnimationSink: AnyCancellable?
    var debugTemplateSink: AnyCancellable?
    var stepNumberSink: AnyCancellable?
    var brushScale = 1.0

    func webView(_ webView: WKWebView,
      didFinish navigation: WKNavigation!) {
        print("WebView ready")
        if taskState.task.path == "DEBUG" {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent("debug.svg")
                do {
                    let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
                    wkWebView.evaluateJavaScript("loadSVG(`\(fileContent)`);") { _, _ in
                        self.onTaskLoaded()
                    }
                } catch {
                    print("Cannot read debug.svg")
                }
            }
        } else {
            if taskState.task.text != nil {
                wkWebView.evaluateJavaScript("loadTextTask(\(taskState.task.text!));") { _, err in
                    self.onTaskLoaded()
                }
                return
            }
            wkWebView.evaluateJavaScript("loadTask(\"\(taskState.task.path)\");") { _, _ in
                self.onTaskLoaded()
            }
        }
    }
    
    func onTaskLoaded() {
        showInputOrTemplate(taskState.stepNumber, template: taskState.debugTemplate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brushScale = Double(view.bounds.height) / 1024
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.userContentController.add(self, name: "control")
        wkWebView = WKWebView(frame: view.bounds, configuration: config)
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = UIColor.clear
        wkWebView.scrollView.backgroundColor = UIColor.clear
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Web/task", ofType: "html")!)
        wkWebView.loadFileURL(url, allowingReadAccessTo: url)
        wkWebView.navigationDelegate = self
        watchUpdates()
        view.addSubview(wkWebView)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
    
    func watchUpdates() {
        skipAnimationSink = taskState.$skipAnimation.sink { [weak self] val in
            self?.wkWebView.evaluateJavaScript("setSkipAnimation(\(val));")
        }
        debugTemplateSink = taskState.$debugTemplate.sink { [weak self] val in
            guard let self = self, self.taskState.debugTemplate != val else {
                return
            }
            self.showInputOrTemplate(self.taskState.stepNumber, template: val)
        }
        stepNumberSink = taskState.$stepNumber.sink { [weak self] val in
            guard let self = self, !self.wkWebView.isLoading else {
                return
            }
            self.onStepNumberChange(val)
        }
    }
    
    func showInputOrTemplate(_ step: Int, template: Bool) {
        wkWebView.evaluateJavaScript(template ? "setShadowSize(\(self.taskState.currentStep.shadowSize * self.brushScale)); showTemplate(\(step));" : "showInput(\(step));")
    }
    
    func onStepNumberChange(_ val: Int) {
        showInputOrTemplate(val, template: taskState.debugTemplate)
    }
}
