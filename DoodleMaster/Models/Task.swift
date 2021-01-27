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
    var brushSize = 10
    var brushOpacity = 1.0
    var shadowSize = 50
    var clearBefore = true
    var showResult = true
    
    var scoringSystem = ScoringSystem()
//    var commitButton = false
//    var dim = false
}

class Task: ObservableObject {
    var name: String
    var path: String // Course.LessonN.TaskN
    var scoringSystem = ScoringSystem() // only for overall result
    var steps: [TaskStep]
    var result: Double {
        get {
            UserDefaults.standard.double(forKey: path + ".taskResult")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: path + ".taskResult")
            objectWillChange.send()
        }
    }
    
    init(name: String, path: String, steps: [TaskStep]) {
        self.name = name
        self.path = path
        self.steps = steps
    }
}
