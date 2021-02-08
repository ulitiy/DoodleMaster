//
//  Task.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct TaskStep: Hashable {
    var brushName = "main"
    var brushSize = 10.0
    var brushOpacity = 1.0
    var shadowSize = 40.0
    var clearBefore = true
    var showResult = true
    
    var scoringSystem = ScoringSystem()
}

class Task: ObservableObject {
    var name: String
    var path: String // Course.TaskN
    var scoringSystem = ScoringSystem() // only for overall result
    var result: Double {
        get {
            UserDefaults.standard.double(forKey: path + ".taskResult")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: path + ".taskResult")
            objectWillChange.send()
        }
    }
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
}
