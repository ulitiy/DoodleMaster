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
    @Published var stepNumber = 1 {
        didSet {
            currentStep = task.steps[stepNumber - 1]
            nextStep = stepNumber < task.steps.count ? task.steps[stepNumber] : nil
        }
    }
    @Published var currentStep: TaskStep!
    @Published var nextStep: TaskStep?
    @Published var currentResult: Result!
    // how many elements there were in canvas.data.elements when this step started
    @Published var stepElementsCount = 0
    @Published var template: MTLTexture? // is updated by Web when assigned to nil
    @Published var taskResult: Result?

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
        currentStep = task.steps[0]
        nextStep = task.steps[1]
        self.task = task
    }
    
    func resetResult() {
        let tc = currentResult?.templateCount
        currentResult = Result(scoringSystem: currentStep.scoringSystem)
        currentResult.templateCount = tc ?? currentResult.templateCount
        currentResultSink = currentResult.objectWillChange.sink(receiveValue: { [weak self] in
            self?.objectWillChange.send() // update self on child update
        })
    }
    
    func passStep() {
        if !passing && taskResult == nil { // only once
            print("Pass step")
            if stepNumber >= task.steps.count {
                passTask()
                return
            }
            passing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + (currentStep.showResult ? 1.6 : 0.2)) { [weak self] in
                self?.switchNextStep()
            }
        }
    }
    
    func failStep() {
        if !failing { // only once
            print("Fail step")
            failing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.restartStep()
            }
        }
    }
    
    func restartStep() {
        print("Restart step")
        resetResult()
        passing = false
        failing = false
    }
    
    func restartTask() {
        print("Restart task")
        results.removeAll()
        stepNumber = 1
        taskResult = nil
        restartStep()
        template = nil
    }
    
    func switchNextStep() {
        print("Next step \(stepNumber)")
        results.append(currentResult)
        stepNumber += 1
        resetResult()
        template = nil
        passing = false
        failing = false
    }
    
    func passTask() {
        results.append(currentResult)
        taskResult = results.reduce(Result(scoringSystem: task.scoringSystem)) { res, val2 in
            res.redK = res.redK + val2.redK / Double(results.count)
            res.greenK = res.greenK + val2.greenK / Double(results.count)
            res.blueK = res.blueK + val2.blueK / Double(results.count)
            res.oneMinusAlphaK = res.oneMinusAlphaK + val2.oneMinusAlphaK / Double(results.count)
            res.overlapK = res.overlapK + val2.overlapK / Double(results.count)
            res.roughnessK = res.roughnessK + val2.roughnessK / Double(results.count)
            res.strokeCountK = res.strokeCountK + val2.strokeCountK / Double(results.count)
            return res
        }
        taskResult!.calculateSummary()
        print("Pass task")
    }
}
