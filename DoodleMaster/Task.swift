//
//  Task.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct ScoringSystem: Hashable {
    // sign * max(abs(c), x<b ? 0 : abs(a*(x-b))) , [b, a, c] array - min val, amplification, max absolute contribution
    var overlap = [0.05, -20.0, 1.0]
    var curvature = [0, -0.005, 1.0]
    var strokeCount = [1, -0.05, 1.0]

    var oneMinusRed = [0.0, -1000, 0.5]
    var green = [0.0, 1.0, 1.0] // THE ONLY POSITIVE
    var blue = [0.0, 0.0, 0.0] // Ignore blue
    var oneMinusAlpha = [0.0, -100, 1.0]

    var passingScore = 95.0
}

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
//  let brushOffset
//  let brushMultiplier
    
    var scoringSystem = ScoringSystem()
}
