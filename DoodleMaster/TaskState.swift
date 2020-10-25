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
            currentResult = Result(scoringSystem: task.scoringSystem)
        }
    }
    @Published var results: [Result] = []
    @Published var stepNumber = 1
    @Published var currentResult: Result!
    @Published var stepSuccess = false
    @Published var stepFailure = false
    
    // I don't know why we have to persist this but updates don't work otherwise
    var anyCancellable: AnyCancellable?
    
    init(task: Task) {
        self.task = task
        anyCancellable = currentResult.objectWillChange.sink(receiveValue: {
            if self.currentResult.overall >= self.currentResult.scoringSystem.passingScore {
                self.stepSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.nextStep()
                }
            }
            self.objectWillChange.send() // update self on child update
        })
    }
    
    func restartStep() {
        currentResult = Result(scoringSystem: task.scoringSystem)
        stepSuccess = false
        stepFailure = false
    }
    
    func restartTask() {
        results.removeAll()
        currentResult = Result(scoringSystem: task.scoringSystem)
        stepNumber = 1
        stepSuccess = false
        stepFailure = false
    }
    
    func nextStep() {
        results.append(currentResult)
        currentResult = Result(scoringSystem: task.scoringSystem)
        stepNumber += 1
        stepSuccess = false
        stepFailure = false
    }
}
