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

struct CanvasContainerRepresentation: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CanvasContainerViewController {
        let controller = CanvasContainerViewController()
        return controller
    }
    
    func updateUIViewController(_ controller: CanvasContainerViewController, context: Context) {
    }
}

class CanvasContainerViewController: UIViewController {
    var canvas: Canvas!
    
    override func viewDidLoad() { // async later
        super.viewDidLoad()
        canvas = Canvas(frame: view.bounds)
        do {
            try canvas.setTemplateTexture(name: "1-template")
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
            fatalError("Template not loaded")
        }
    }
}
