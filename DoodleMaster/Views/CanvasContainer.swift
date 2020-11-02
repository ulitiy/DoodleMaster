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

    override func viewDidLoad() { // async later
        super.viewDidLoad()
        canvas = Canvas(frame: view.bounds)
        let brush = try! canvas.registerBrush(name: "main")
        brush.forceSensitive = 0.5
        brush.pointSize = 10
        brush.opacity = 0.3
        
        let shadowBrush = try! canvas.registerBrush(name: "shadow")
        shadowBrush.forceSensitive = 0
        shadowBrush.pointSize = 50
        shadowBrush.opacity = 0.05 // cannot be lower because of the 1 byte precision
        watchUpdates()
        view.addSubview(canvas)
        brush.use()
        shadowBrush.useShadow()
    }
    
    func watchUpdates() {
        canvas.onTemplateCountCompleted = { res in
            self.taskState.currentResult.templateCount = res
        }
        canvas.onCountCompleted = { res in
            self.taskState.currentResult.matchResults = res
        }
        canvas.onTouchesBegan = {
            self.taskState.touching = true
        }
        canvas.onTouchesEnded = {
            self.taskState.currentResult.strokeCount = self.canvas.data.elements.count
            self.taskState.touching = false
        }
        // Next step
        stepNumberSink = taskState.$stepNumber.sink { val in
            if val <= self.taskState.stepNumber {
                return
            }
            self.canvas.clear()
        }
        // Restart step
        failingSink = taskState.$failing.sink { val in
            if val {
                return
            }
            self.canvas.clear()
        }
        // New step template ready
        templateSink = taskState.$template.sink { val in
            guard let val = val else {
                return
            }
            try! self.canvas.setTemplateTexture(val)
        }
    }
}
