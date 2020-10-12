//
//  Task.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct ScoringSystem: Hashable {
    // xa, ya, xb, yb clamp x and interpolate
    var overlap = [0.3, 0.0, 0.7, -1.0]
    var curvature = [0.0, 0.0, 1.0, -0.3]
    var strokeCount = [1.0, 0.0, 3.0, -1.0]

    var red = [0.0, -1.0, 1.0, 0.0]
    var green = [0.0, 0.0, 1.0, 1.0]
    var blue = [0.0, 0.0, 1.0, 0.0]
    var oneMinusAlpha = [0.0, 0.0, 0.005, -1]

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
