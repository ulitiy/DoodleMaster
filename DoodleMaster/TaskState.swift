//
//  TaskState.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 24.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine
import UIKit

class TaskState: ObservableObject {
    @Published var task: Task! {
        didSet {
            resetResult()
        }
    }
    @Published var results: [Result] = []
    @Published var stepNumber = 1
    @Published var currentResult: Result!
    @Published var template: MTLTexture?
    
    @Published var touching = false {
        didSet {
            if touching {
                return
            }
            if self.currentResult.passed {
                self.passStep()
            }
            if self.currentResult.failed {
                self.failStep()
            }
        }
    }
    @Published var passing = false
    @Published var failing = false
    
    var currentResultSink: AnyCancellable?
    
    init(task: Task) {
        self.task = task
    }
    
    func setTemplate(temp: MTLTexture) {
        template = temp
    }
    
    func resetResult() {
        let tc = currentResult?.templateCount
        currentResult = Result(scoringSystem: task.scoringSystem)
        currentResult.templateCount = tc ?? currentResult.templateCount
        currentResultSink = currentResult.objectWillChange.sink(receiveValue: {
            self.objectWillChange.send() // update self on child update
        })
    }
    
    func passStep() {
        if !passing { // only once
            passing = true
            template = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.nextStep()
            }
        }
    }
    
    func failStep() {
        if !failing { // only once
            failing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.restartStep()
            }
        }
    }
    
    func restartStep() {
        resetResult()
        passing = false
        failing = false
    }
    
    func restartTask() {
        results.removeAll()
        resetResult()
        stepNumber = 1
        passing = false
        failing = false
    }
    
    func nextStep() {
        results.append(currentResult)
        resetResult()
        stepNumber += 1
        passing = false
        failing = false
    }
}
