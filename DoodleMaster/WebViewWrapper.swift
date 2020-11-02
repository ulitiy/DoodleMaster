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

class WebViewController: UIViewController, WKNavigationDelegate {
    var taskState: TaskState!
    var wkWebView: WKWebView!
    var passingSink: AnyCancellable?
    var failingSink: AnyCancellable?

    func webView(_ webView: WKWebView,
      didFinish navigation: WKNavigation!) {
        print("didFinish")
        wkWebView.evaluateJavaScript("loadTask(\"\(taskState.task.path)\");", completionHandler: { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // 0.02 enough on mac
                self.takeSnapshot(step: self.taskState.stepNumber)
            }
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        print("WK Nav error")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
        print("WK Provisional error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
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
        passingSink = taskState.$passing.sink { val in
            if (val == false) {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.wkWebView.evaluateJavaScript("showTemplate(\(self.taskState.stepNumber + 1));")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.takeSnapshot(step: self.taskState.stepNumber + 1)
            }
        }
        failingSink = taskState.$failing.sink { val in
            if (val == false) {
                return;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.wkWebView.evaluateJavaScript("restart();")
            }
        }
    }
    
    func takeSnapshot(step: Int) {
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true
        config.snapshotWidth = 320 // multiple of 32 is better
        wkWebView.takeSnapshot(with: config, completionHandler: { img, _ in
            self.wkWebView.evaluateJavaScript("showInput(\(step));") // here because ASAP
            self.taskState.setTemplate(temp: self.createTexture(uiImage: img!)!)
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
