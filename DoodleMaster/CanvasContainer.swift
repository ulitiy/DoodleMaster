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
        controller.templateSink = taskState.$template.sink { val in
            guard let val = val else {
                return
            }
            try! controller.canvas.setTemplateTexture(val)
        }
        return controller
    }

    func updateUIViewController(_ controller: CanvasContainerViewController, context: Context) {
        controller.canvas.onTemplateCountCompleted = { res in
            taskState.currentResult.templateCount = res
        }
        controller.canvas.onCountCompleted = { res in
            taskState.currentResult.matchResults = res
        }
        controller.canvas.onTouchesBegan = {
            taskState.touching = true
        }
        controller.canvas.onTouchesEnded = {
            taskState.currentResult.strokeCount = controller.canvas.data.elements.count
            taskState.touching = false
        }
        // TODO: rewrite with sinks
        updateStepNumber(controller: controller)
        updateFailed(controller: controller)
    }
    
    // TODO: Move to controller
    func updateStepNumber(controller: CanvasContainerViewController) {
        if taskState.stepNumber == controller.stepNumber
            || taskState.stepNumber > taskState.task.stepCount {
            return
        }
//        controller.setTemplateTexture(name: "Courses/\(taskState.task.path)/\(taskState.stepNumber).temp")
        controller.stepNumber = taskState.stepNumber
        controller.canvas.clear()
    }
    
    // TODO: Move to controller
    func updateFailed(controller: CanvasContainerViewController) {
        if !taskState.failing && controller.failing {
            controller.canvas.clear()
        }
        controller.failing = taskState.failing
    }
}

class CanvasContainerViewController: UIViewController {
    var taskState: TaskState!
    var canvas: Canvas!
    var stepNumber = 1
    var failing = false
    var templateSink: AnyCancellable?
    
    override func viewDidLoad() { // async later
        super.viewDidLoad()
        canvas = Canvas(frame: view.bounds)
        do {
            let brush = try canvas.registerBrush(name: "main")
            brush.forceSensitive = 0.5
            brush.pointSize = 10
            brush.opacity = 0.3
            
            let shadowBrush = try canvas.registerBrush(name: "shadow")
            shadowBrush.forceSensitive = 0
            shadowBrush.pointSize = 50
            shadowBrush.opacity = 0.05 // cannot be lower because of the 1 byte precision
            view.addSubview(canvas)
            brush.use()
            shadowBrush.useShadow()
        } catch {
            fatalError("Brush not registered")
        }
    }
}
