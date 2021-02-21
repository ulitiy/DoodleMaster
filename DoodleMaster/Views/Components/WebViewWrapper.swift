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
    var stepNumberSink: AnyCancellable?
    var failingSink: AnyCancellable?
    var templateSink: AnyCancellable?
    var skipAnimationSink: AnyCancellable?
    var debugTemplateSink: AnyCancellable?
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
                        self.getTaskSettings()
                    }
                } catch {
                    print("Cannot read debug.svg")
                }
            }
        } else {
            if taskState.task.text != nil {
                wkWebView.evaluateJavaScript("loadTextTask(\(taskState.task.text!));") { _, err in
                    self.getTaskSettings()
                }
                return
            }
            wkWebView.evaluateJavaScript("loadTask(\"\(taskState.task.path)\");") { _, _ in
                self.getTaskSettings()
            }
        }
    }
    
    func getTaskSettings() {
        self.wkWebView.evaluateJavaScript("countSteps();") { res, _ in
            guard let res = res as? Int else {
                return
            }
            self.taskState.stepCount = res
        }
        self.getStepSettings(self.taskState.stepNumber) {
            self.wkWebView.evaluateJavaScript("setShadowSize(\(self.taskState.currentStep.shadowSize * self.brushScale)); showTemplate(\(self.taskState.stepNumber));")
        }
    }
    
    // receives js event messages
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("JS - \(message.name): \(message.body)")
        if let body = message.body as? String, body == "TemplateReady" {
            self.takeSnapshot(step: self.taskState.stepNumber)
        }
        if let body = message.body as? String, body == "InputReady" {
            self.taskState.template = self.createTexture(uiImage: snapshot!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        brushScale = Double(view.bounds.height) / 1024
        view.addSubview(wkWebView)
    }
    
    func watchUpdates() {
        failingSink = taskState.$failing.sink { [weak self] val in
            guard let self = self, self.taskState.failing, !val else {
                return;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self else {
                    return;
                }
                self.wkWebView.evaluateJavaScript("restart();")
                if self.taskState.debugTemplate {
                    self.wkWebView.evaluateJavaScript("showTemplate(\(self.taskState.stepNumber));")
                }
            }
        }
        templateSink = taskState.$template.sink { [weak self] val in
            if val == nil {
                self?.wkWebView.evaluateJavaScript("setShadowSize(\(self!.taskState.currentStep.shadowSize * self!.brushScale)); showTemplate(\(self!.taskState.stepNumber));")
            }
        }
        skipAnimationSink = taskState.$skipAnimation.sink { [weak self] val in
            self?.wkWebView.evaluateJavaScript("setSkipAnimation(\(val));")
        }
        debugTemplateSink = taskState.$debugTemplate.sink { [weak self] val in
            guard let self = self, self.taskState.debugTemplate != val else {
                return
            }
            self.wkWebView.evaluateJavaScript(val ? "showTemplate(\(self.taskState.stepNumber));" : "showInput(\(self.taskState.stepNumber));")
        }
        stepNumberSink = taskState.$stepNumber.sink { [weak self] val in
            guard let self = self, !self.wkWebView.isLoading else {
                return
            }
            self.getStepSettings(val) {}
        }
    }
    
    func getStepSettings(_ step: Int, cl: @escaping () -> Void) {
        self.wkWebView.evaluateJavaScript("getStepSettings(\(step));") { res, _ in
            guard let res = res as? String else {
                return
            }
            self.taskState.currentStep = stepTemplates[res] ?? stepTemplates["default"]
            print("Using step template \(res)")
            cl()
        }
    }
    
    var snapshot: UIImage?
    func takeSnapshot(step: Int) {
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true
        config.snapshotWidth = 512 // (points, means x2 px) multiple of 32 is better
        print("Taking screenshot...")
        wkWebView.takeSnapshot(with: config, completionHandler: { [weak self] img, err in
            guard let self = self else {
                return
            }
            self.snapshot = img
            if !self.taskState.debugTemplate {
                self.wkWebView.evaluateJavaScript("showInput(\(step));") // standard behavior
            } else {
                self.taskState.template = self.createTexture(uiImage: self.snapshot!) // debug behavior. Because we skip InputReady event
            }
        })
    }
    
    func createTexture(uiImage: UIImage) -> MTLTexture? {
        guard let cgImage = uiImage.cgImage,
              let device = MTLCreateSystemDefaultDevice() else {
            return nil
        }
        
        let context = CGContext(data: nil,
                                width: Int(cgImage.width),
                                height: Int(cgImage.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: cgImage.bitmapInfo.rawValue)!
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: cgImage.width, height: cgImage.height, mipmapped: false)
        let tex = device.makeTexture(descriptor: d)!
        
        swapColors(context.data!, count: context.width * context.height)
        tex.replace(region: MTLRegionMake2D(0, 0, context.width, context.height),
                    mipmapLevel: 0,
                    withBytes: context.data!,
                    bytesPerRow: context.width * 4)
        return tex
    }
    
    func swapColors(_ pointer: UnsafeMutableRawPointer, count: Int) {
        let ptr = pointer.assumingMemoryBound(to: UInt8.self)
        for i in 0...count {
            let r = ptr[i * 4]
            ptr[i *  4] = ptr[i * 4 + 2]
            ptr[i * 4 + 2] = r
        }
    }
}
