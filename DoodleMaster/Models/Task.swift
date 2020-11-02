//
//  Task.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct TaskStep: Hashable {
//    var scoringSystem: ScoringSystem? = nil // no need for different for MVP
    var CommitButton = false

// only cleaning steps for MVP
//    var cleanFinal = false
//    var cleanShadow = false
//    var dim = false
//    var brush = false // "pencil", "pen", "brush"
}

// no undos and undo steps for MVP
// redo steps are required
struct Task: Hashable {
    var name: String
    var path: String // CourseN.LessonN.TaskN.StepN
    var stepCount = 1
//  let brushOffset
//  let brushMultiplier
    
    var scoringSystem = ScoringSystem()
}
