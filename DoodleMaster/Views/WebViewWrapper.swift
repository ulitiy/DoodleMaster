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

    func webView(_ webView: WKWebView,
      didFinish navigation: WKNavigation!) {
        wkWebView.evaluateJavaScript("loadTask(\"\(taskState.task.path)\");")
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
        view.addSubview(wkWebView)
    }
    
    func watchUpdates() {
        failingSink = taskState.$failing.sink { [weak self] val in
            if !val {
                return;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.wkWebView.evaluateJavaScript("restart();")
            }
        }
        templateSink = taskState.$template.sink { [weak self] val in
            if val == nil {
                self?.wkWebView.evaluateJavaScript("showTemplate(\(self!.taskState.stepNumber));")
            }
        }
    }
    
    var snapshot: UIImage?
    func takeSnapshot(step: Int) {
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true
        config.snapshotWidth = 160 // (points, means x2 px) multiple of 32 is better
        print("Taking screenshot...")
        wkWebView.takeSnapshot(with: config, completionHandler: { [weak self] img, err in
            self?.snapshot = img
            self?.wkWebView.evaluateJavaScript("showInput(\(step));")
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
