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

struct CanvasContainerRepresentation: UIViewControllerRepresentable {
    @ObservedObject var taskState: TaskState

    func makeUIViewController(context: Context) -> CanvasContainerViewController {
        let controller = CanvasContainerViewController()
        controller.taskState = taskState
        return controller
    }

    func updateUIViewController(_ controller: CanvasContainerViewController, context: Context) {
    }
}

class CanvasContainerViewController: UIViewController {
    var taskState: TaskState!
    var canvas: Canvas!
    var templateSink: AnyCancellable?
    var stepNumberSink: AnyCancellable?
    var failingSink: AnyCancellable?
    var stepSink: AnyCancellable?

    override func viewDidLoad() { // async later
        super.viewDidLoad()
        canvas = Canvas(frame: view.bounds)
        let brush = try! canvas.registerBrush(name: "main")
        brush.forceSensitive = 0.5
        brush.pointSize = 10
        brush.opacity = 0.3
        
        let texture = try! canvas.makeTexture(with: UIImage(named: "pencil")!.pngData()!)
        let pencil = try! canvas.registerBrush(name: "pencil", textureID: texture.id)
        pencil.rotation = .random
        pencil.pointSize = 3
        pencil.forceSensitive = 0.3
        pencil.opacity = 1

        
        let shadowBrush = try! canvas.registerBrush(name: "shadow")
        shadowBrush.forceSensitive = 0
        shadowBrush.pointSize = 10 // overriden by currentStep
        shadowBrush.opacity = 0.05 // 0.05 cannot be lower because of the 1 byte precision
        watchUpdates()
        view.addSubview(canvas)
        brush.use()
        shadowBrush.useShadow()
        setBrushes(step: taskState.currentStep)
    }
    
    func watchUpdates() {
        canvas.onTemplateCountCompleted = { [weak self] res in
            self?.taskState.currentResult.templateCount = res
            print("Template count: \(res)")
            if res[2] == 0 {
                self?.taskState.template = nil
                print("No blues in the screenshot, resetting...")
            }
        }
        canvas.onCountCompleted = { [weak self] res in
            self?.taskState.currentResult.rippleSum = self!.canvas.rippleSum * 512 // it's just how I calculated initially, no biggie
            self?.taskState.currentResult.rippleCount = self!.canvas.rippleCount
            self?.taskState.currentResult.matchResults = res
        }
        canvas.onTouchesBegan = { [weak self] in
            self?.taskState.touching = true
        }
        canvas.onTouchesEnded = { [weak self] in
            self?.taskState.currentResult.strokeCount = self!.canvas.data.elements.count // TODO: seems reliable
            self?.taskState.touching = false
        }
        // Next step or restart task
        stepNumberSink = taskState.$stepNumber.sink { [weak self] val in
            guard let self = self else {
                return
            }
            if val == 1 { // restart task
                self.taskState.stepElementsCount = 0
                self.canvas.clear()
                return
            }
            if val <= self.taskState.stepNumber {
                return
            }
            self.taskState.stepElementsCount = self.canvas.data.elements.count
            if self.taskState.task.steps[val - 1].clearBefore {
                self.canvas.clear()
            }
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
        }
    }
    
    func setBrushes(step: TaskStep) {
        let brush = self.canvas.registeredBrushes.first(where: { $0.name == step.brushName })
        brush?.use()
        self.canvas.shadowBrush.pointSize = CGFloat(step.shadowSize)
        self.canvas.currentBrush.pointSize = CGFloat(step.brushSize)
        self.canvas.currentBrush.opacity = CGFloat(step.brushOpacity)
    }
}
