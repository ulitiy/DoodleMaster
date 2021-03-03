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
    var shadowSize = 50.0
    var clearBefore = true
    var showResult = true
    
    var scoringSystem = ScoringSystem()
    
    init(template: TaskStep? = nil, brushName: String? = nil, brushSize: Double? = nil, brushOpacity: Double? = nil, shadowSize: Double? = nil,
         clearBefore: Bool? = nil, showResult: Bool? = nil, scoringSystem: ScoringSystem? = nil) {
        self.brushName = brushName ?? template?.brushName ?? "main"
        self.brushSize = brushSize ?? template?.brushSize ?? 10.0
        self.brushOpacity = brushOpacity ?? template?.brushOpacity ?? 1.0
        self.shadowSize = shadowSize ?? template?.shadowSize ?? 50.0
        self.clearBefore = clearBefore ?? template?.clearBefore ?? true
        self.showResult = showResult ?? template?.showResult ?? true
        self.scoringSystem = scoringSystem ?? template?.scoringSystem ?? ScoringSystem()
    }
}

class Task: ObservableObject {
    var name: String
    var path: String // Course.TaskN
    var text: [String]?
    var scoringSystem = ScoringSystem() // only for overall result
    var result: Double {
        get {
            UserDefaults.standard.double(forKey: path + ".taskResult")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: path + ".taskResult")
            print("Setting \(newValue) for \(path + ".taskResult")")
            objectWillChange.send()
        }
    }
    
    init(name: String, path: String, text: [String]? = nil) {
        self.name = name
        self.path = path
        self.text = text
    }
}
