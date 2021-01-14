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
    var task: Task! {
        didSet {
            resetResult()
        }
    }
    var results: [Result] = []
    @Published var stepNumber = 1 {
        didSet {
            currentStep = task.steps[stepNumber - 1]
        }
    }
    @Published var currentStep: TaskStep!
    @Published var currentResult: Result!
    // how many elements there were in canvas.data.elements when this step started
    var stepElementsCount = 0
    @Published var template: MTLTexture? // is updated by Web when assigned to nil
    @Published var taskResult: Result?

    @Published var touching = false {
        didSet {
            guard !touching else {
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
    @Published var highScore = false
    @Published var whyFailed: String?
    var dateStarted: Date!
    
    @Published var skipAnimation = false
    
    var currentResultSink: AnyCancellable?
    
    init(task: Task) {
        currentStep = task.steps[0]
        self.task = task
        dateStarted = Date()
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
            currentResult.print()
            if currentStep.showResult { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.switchNextStep()
            }
        }
    }
    
    func failStep() {
        if !failing { // only once
            print("Fail step")
            failing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else {
                    return
                }
                self.whyFailed = self.currentResult.whyFailed
                self.restartStep()
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
        dateStarted = Date()
    }
    
    func switchNextStep() {
        whyFailed = nil
        results.append(currentResult)
        stepNumber += 1
        print("Next step \(stepNumber)")
        resetResult()
        template = nil
        passing = false
        failing = false
    }
    
    func passTask() {
        results.append(currentResult)
        let totalWeight = task.steps.reduce(0, { res, step in
            return res+step.scoringSystem.weight
        })
        taskResult = results.reduce(Result(scoringSystem: task.scoringSystem)) { res, val2 in
            let weight = val2.scoringSystem.weight / totalWeight
            res.redK = res.redK + val2.redK * weight
            res.greenK = res.greenK + val2.greenK * weight
            res.blueK = res.blueK + val2.blueK * weight
            res.oneMinusAlphaK = res.oneMinusAlphaK + val2.oneMinusAlphaK * weight
            res.overlapK = res.overlapK + val2.overlapK * weight
            res.roughnessK = res.roughnessK + val2.roughnessK * weight
            res.strokeCountK = res.strokeCountK + val2.strokeCountK * weight
            print("Step result: \(val2.overall.formatPercent(3)) * \(weight.toString(3)) = \((val2.overall * weight).formatPercent(3))")
            return res
        }
        // *K is always correct, no formula is applied on the summary step
        taskResult!.calculateSummary()
        if taskResult!.overall > task.result {
            task.result = taskResult!.overall
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.highScore = true
            }
        }
        print("Pass task, result:")
        taskResult!.print()
        print("=========")
    }
}
