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

struct Task: Hashable {
    var name: String
    var path: String // Course.LessonN.TaskN
    var scoringSystem = ScoringSystem() // only for overall result
    var steps: [TaskStep] = []
}
