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
    @Published var task: Task! // has to be published

    var results: [Result] = []
    @Published var stepNumber = 0
    @Published var currentStep: TaskStep! {
        didSet {
            resetResult()
        }
    }
    @Published var currentResult: Result!
    // how many elements there were in canvas.data.elements when this step started
    var totalWeight = 0.0
    var stepElementsCount = 0
    @Published var stepCount = 0
    @Published var template: MTLTexture? // is updated by Web when assigned to nil
    @Published var taskResult: Result?
    
    @Published var touching = false {
        didSet {
            guard !touching else {
                return
            }
            if currentResult.passed && self.template != nil { // may be no new screenshot yet?
                self.passStep()
            }
            if currentResult.failed {
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
    @Published var debugTemplate = false
    
    var currentResultSink: AnyCancellable?
    
    init(task: Task) {
        self.task = task
        currentStep = TaskStep()
        dateStarted = Date() // TODO: issue here when not lazy loaded?
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
            if stepNumber >= stepCount - 1 {
                passTask()
                return
            }
            passing = true
//            currentResult.print()
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
        stepNumber = 0
        totalWeight = 0
        stepElementsCount = 0
        taskResult = nil
        restartStep()
        template = nil
        dateStarted = Date()
    }
    
    func switchNextStep() {
        whyFailed = nil
        totalWeight += currentStep.scoringSystem.weight
        results.append(currentResult)
        stepNumber += 1
        print("Next step \(stepNumber)")
        resetResult()
        template = nil
        passing = false
        failing = false
    }
    
    func passTask() {
        totalWeight += currentStep.scoringSystem.weight
        results.append(currentResult)
        taskResult = results.reduce(Result(scoringSystem: task.scoringSystem)) { res, val2 in
            let weight = val2.scoringSystem.weight / totalWeight
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
