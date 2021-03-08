//
//  TaskState.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 24.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine
import UIKit
import Amplitude_iOS

enum MatchState {
    case requested
    case inProgress
    case idle
}

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
    var timesFailed = 0
    var stepElementsCount = 0
    var defaultStep = TaskStep()
    @Published var stepCount = 0
    @Published var template: MTLTexture? // is updated by Web when assigned to nil
    @Published var taskResult: Result?
    
    var matchTimer: Timer?
    
    @Published var touching = false {
        didSet {
            if touching {
                print("Touching")
                matchTimer?.invalidate() // necessary to invalidate accidental timer
                matchTimer = Timer.scheduledTimer(withTimeInterval: 0.03 , repeats: true) { [weak self] _ in // 0.03 x 512pts @ 60fps 60%gpu, 0.02 x 512pts @ 60fps 71% gpu
                    self?.requestMatchCount()
                }
                return
            }
            print("NTouching")
            matchTimer?.invalidate()
            matchTimer = nil
            requestMatchCount()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in // TODO: needs refactoring but works well
                guard let self = self else { return }
                self.currentResult.print()
                if self.currentResult.passed && self.template != nil { // may be no new screenshot yet?
                    self.passStep()
                }
                if self.currentResult.failed {
                    self.failStep()
                }
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
    @Published var matchState = MatchState.idle
    
    var currentResultSink: AnyCancellable?
    
    init(task: Task) {
        self.task = task
        currentStep = TaskStep()
        dateStarted = Date() // TODO: issue here when not lazy loaded?
    }
    
    func requestMatchCount() {
        matchState = .requested
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
            Amplitude.instance().logEvent("step_pass", withEventProperties: [
                "task_path": task.path,
                "step_number": stepNumber,
                "name": task.name,
                "result_details": currentResult.toDictionary(),
                "times_failed": timesFailed,
            ])
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
            timesFailed += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else {
                    return
                }
                self.whyFailed = self.currentResult.whyFailed
                self.restartStep()
            }
            Amplitude.instance().logEvent("step_fail", withEventProperties: [
                "task_path": task.path,
                "step_number": stepNumber,
                "name": task.name,
                "result_details": currentResult.toDictionary(),
                "times_failed": timesFailed,
            ])
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
        timesFailed = 0
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
        timesFailed = 0
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
        Amplitude.instance().logEvent("task_pass", withEventProperties: [
            "path": task.path,
            "name": task.name,
            "highscore": highScore,
            "result": taskResult!.toDictionary(),
            "time": abs(dateStarted.timeIntervalSinceNow),
        ])
    }
}
