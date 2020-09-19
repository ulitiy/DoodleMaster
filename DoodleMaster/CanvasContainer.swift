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
            let shadowBrush = try canvas.registerBrush(name: "shadow")
            shadowBrush.forceSensitive = 0.1
//            shadowBrush.opacity = 1 // works poorly
//            shadowBrush.opacity = 90
            shadowBrush.pointSize = 200
            view.addSubview(canvas)
//            shadowBrush.use()
            shadowBrush.useShadow()
        } catch {
            fatalError("Template not loaded")
        }
//        canvas.backgroundColor = .blue
    }
}
