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
        canvas.onTemplateCountCompleted = { [weak self] res in
            self?.taskState.currentResult.templateCount = res
            if res[1] == 0 {
                self?.taskState.template = nil
                print("Broken screenshot, resetting...")
            }
        }
        canvas.onCountCompleted = { [weak self] res in
            self?.taskState.currentResult.matchResults = res
        }
        canvas.onTouchesBegan = { [weak self] in
            self?.taskState.touching = true
        }
        canvas.onTouchesEnded = { [weak self] in
            self?.taskState.currentResult.strokeCount = self!.canvas.data.elements.count
            self?.taskState.touching = false
        }
        // Next step
        stepNumberSink = taskState.$stepNumber.sink { [weak self] val in
            if val <= self?.taskState.stepNumber ?? 0 {
                return
            }
            self?.canvas.clear()
        }
        // Restart step
        failingSink = taskState.$failing.sink { [weak self] val in
            if val {
                return
            }
            self?.canvas.clear()
        }
        // New step template ready
        templateSink = taskState.$template.sink { [weak self] val in
            guard let val = val else {
                return
            }
            try! self?.canvas.setTemplateTexture(val)
        }
    }
}