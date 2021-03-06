//
//  CanvasContainer.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import UIKit
import SwiftUI
import MaLiang
import Combine
import Amplitude_iOS

struct CanvasWrapper: UIViewControllerRepresentable {
    @ObservedObject var taskState: TaskState

    func makeUIViewController(context: Context) -> CanvasWrapperController {
        let controller = CanvasWrapperController()
        controller.taskState = taskState
        return controller
    }

    func updateUIViewController(_ controller: CanvasWrapperController, context: Context) {
    }
}

class CanvasWrapperController: UIViewController {
    var taskState: TaskState!
    var canvas: Canvas!
    var templateSink: AnyCancellable?
    var failingSink: AnyCancellable?
    var stepSink: AnyCancellable?
    var debugTemplateSink: AnyCancellable?
    var passingSink: AnyCancellable?
    var matchState: AnyCancellable?
    var brushScale = CGFloat(1)
    
    override func viewDidLoad() { // async later
        super.viewDidLoad()
        canvas = Canvas(frame: view.bounds)
//        print("Canvas size: \(view.bounds)")
        brushScale = view.bounds.height / 1024
        let brush = try! canvas.registerBrush(name: "main")
        brush.opacity = 1
        brush.forceSensitive = 0.5
        
        let pen = try! canvas.registerBrush(name: "pen")
        pen.opacity = 0.9
        pen.forceSensitive = 0.1

        let texture = try! canvas.makeTexture(with: UIImage(named: "pencil")!.pngData()!)
        let pencil = try! canvas.registerBrush(name: "pencil", textureID: texture.id)
        pencil.rotation = .random
        pencil.pointStep = 2
        pencil.forceSensitive = 0.1
        pencil.opacity = 1
        pencil.color = UIColor(white: 0.3, alpha: 1)
        
        let shadowBrush = try! canvas.registerBrush(name: "shadow")
        shadowBrush.forceSensitive = 0
        shadowBrush.opacity = 0.2 // 0.05 cannot be lower because of the 1 byte precision
        watchUpdates()
        view.addSubview(canvas)
        brush.use()
        shadowBrush.useShadow()
        setBrushes(step: taskState.currentStep)
    }
    
    func watchUpdates() {
        canvas.onTemplateCountCompleted = { [weak self] res in
            self?.taskState.currentResult.templateCount = res
            if res[0] == 0 {
                self?.taskState.template = nil
                print("No red in the screenshot, resetting...")
            }
            self?.canvas.keepFirst(self!.taskState.stepElementsCount)
        }
        matchState = taskState.$matchState.sink { [weak self] val in
            if val == .requested {
                self?.taskState.matchState = .inProgress
                try! self?.canvas.countMatchPixels()
            }
        }
        canvas.onCountCompleted = { [weak self] res in
            guard let self = self, self.taskState.touching else { return }
            self.taskState.currentResult.rippleSum = self.canvas.rippleSum
            self.taskState.currentResult.ripplePageCount = self.canvas.ripplePageCount
            self.taskState.currentResult.matchResults = res
        }
        
        canvas.onTouchesBegan = { [weak self] in
            self?.taskState.touching = true
        }
        canvas.onTouchesEnded = { [weak self] in
            guard let self = self else { return }
            self.taskState.currentResult.strokeCount = self.canvas.data.elements.count // TODO: seems reliable
            self.taskState.touching = false
            if self.canvas.isPencilMode {
                Amplitude.instance().setUserProperties(["has_apple_pencil": true])
            }
        }
        passingSink = taskState.$passing.sink { [weak self] val in
            guard let self = self, !self.taskState.passing, val else {
                return
            }
            self.canvas.clearShadow()
            self.taskState.stepElementsCount = self.canvas.data.elements.count // can't be done in stepNumberSink because too late, can slip stroke
        }
        // Restart step
        failingSink = taskState.$failing.sink { [weak self] val in
            guard let self = self, self.taskState.failing, !val else {
                return
            }
            if self.taskState.currentStep.clearBefore {
                self.canvas.clear()
            } else {
                self.canvas.keepFirst(self.taskState.stepElementsCount)
            }
        }
        // New step template ready
        templateSink = taskState.$template.sink { [weak self] val in
            guard let self = self, let val = val else {
                return
            }
            try! self.canvas.setTemplateTexture(val)
        }
        stepSink = taskState.$currentStep.sink { [weak self] val in
            guard let self = self, let val = val else {
                return
            }
            self.setBrushes(step: val)
            if val.clearBefore {
                self.canvas.clear()
            }
        }
        debugTemplateSink = taskState.$debugTemplate.sink { [weak self] val in
            self?.canvas.showShadow = val
            self?.canvas.redraw()
        }
    }
    
    func setBrushes(step: TaskStep) {
        let brush = self.canvas.registeredBrushes.first(where: { $0.name == step.brushName })
        brush?.use()
        self.canvas.shadowBrush.pointSize = CGFloat(step.shadowSize) * brushScale
        self.canvas.currentBrush.pointSize = CGFloat(step.brushSize) * brushScale
    }
}
