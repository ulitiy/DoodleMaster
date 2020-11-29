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
    var shadowSize = 50
    var commitButton = false
    var scoringSystem = ScoringSystem()
    var clearBefore = true
    var showResult = true
    
//    var dim = false
}

class Task: ObservableObject {
    @Published var name: String
    @Published var path: String // Course.LessonN.TaskN
    @Published var scoringSystem = ScoringSystem() // only for overall result
    @Published var steps: [TaskStep]
    @Published var result = 0.0 {
        didSet {
            UserDefaults.standard.set(result, forKey: path + ".taskResult")
        }
    }
    
    init(name: String, path: String, steps: [TaskStep]) {
        self.name = name
        self.path = path
        self.steps = steps
        self.result = UserDefaults.standard.double(forKey: path + ".taskResult")
    }
}
