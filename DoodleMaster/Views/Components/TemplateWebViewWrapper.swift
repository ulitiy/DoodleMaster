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

struct TemplateWebViewWrapper : UIViewControllerRepresentable {
    @ObservedObject var taskState: TaskState
    
    func makeUIViewController(context: Context) -> TemplateWebViewController {
        let controller = TemplateWebViewController()
        controller.taskState = taskState
        return controller
    }
    
    func updateUIViewController(_ controller: TemplateWebViewController, context: Context) {
    }
}

class TemplateWebViewController: WebViewController {
    var templateSink: AnyCancellable?

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
    
    override func onTaskLoaded() {
        self.getTaskSettings()
    }
    
    // receives js event messages
    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("JS - \(message.name): \(message.body)")
        if let body = message.body as? String, body == "TemplateReady" {
            self.takeSnapshot(step: self.taskState.stepNumber)
        }
    }
    
    override func watchUpdates() {
        templateSink = taskState.$template.sink { [weak self] val in
            if val == nil {
                self?.wkWebView.evaluateJavaScript("setShadowSize(\(self!.taskState.currentStep.shadowSize * self!.brushScale)); showTemplate(\(self!.taskState.stepNumber));")
            }
        }
        stepNumberSink = taskState.$stepNumber.sink { [weak self] val in // duplicates WVW
            guard let self = self, !self.wkWebView.isLoading else {
                return
            }
            self.onStepNumberChange(val)
        }
    }
    
    override func onStepNumberChange(_ val: Int) {
        self.getStepSettings(val) {}
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
            self.taskState.template = self.createTexture(uiImage: self.snapshot!) // debug behavior. Because we skip InputReady event
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