//
//  Result.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 07.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

let neutral = [0.0, 0.0, 1, 0.0]
let any = [0.0, 0.0, 0.03, 1.0, 1.0]
let oneStroke = [1.0, 0.0, 2.0, -1.0]
let necessary = [0.9699, 0.0, 0.97, -1.0]
let smooth = [0.6, 0.0, 0.7, -1.0]
let rough = [6.0, -1.0, 7.0, 0.0]

struct ScoringSystem: Hashable {
    // xa, ya, xb, yb line coordinates, clamp x and interpolate
    var overlap = neutral
    var roughness = neutral // 0-1 very smooth 1-3 okish 3+ bad
    var strokeCount = neutral

//    var red = neutral // debug
    var red = necessary // necessary, sharp line
    var green = neutral // neutral
    var blue = [0.0, 0.0, 1.0, 1.0, 0.95] // good, match, 5th value - minimum blue
    var oneMinusAlpha = [0.0, 0.0, 0.01, -1] // bad, deviation

//    var passingScore = 0.7 // debug
    var passingScore = 0.9
    var weight = 1.0
}

class Result: ObservableObject {
    @Published var matchResults: [UInt32] = [0, 0, 0, 0, 0, 0] {
        didSet {
            calculate()
        }
    }
    
    @Published var templateCount: [UInt32] = [0, 0, 0, 0]
    @Published var strokeCount = 0 {
        didSet {
            calculate()
            print()
        }
    }
    @Published var rippleSum = 0.0
    @Published var rippleCount = 0
    // Add time
    // Add length

    @Published var scoringSystem: ScoringSystem
    
    init(scoringSystem: ScoringSystem) {
        self.scoringSystem = scoringSystem
    }
    
    @Published var overall = 0.0
    @Published var passed = false
    @Published var failed = false
    @Published var positive = 0.0
    @Published var negative = 0.0
    @Published var enoughBlueK = false // can override overall -> passed

    @Published var overlapK = 0.0
    @Published var roughnessK = 0.0
    @Published var strokeCountK = 0.0
    var strokeCountPlusOneK = 0.0
    @Published var redK = 0.0
    @Published var greenK = 0.0
    @Published var blueK = 0.0
    @Published var oneMinusAlphaK = 0.0
    @Published var whyFailed: String?
    
    func calculateK(val: Double = 0, scoring: [Double] = [0.0, 0.0, 1.0, 0.0]) -> Double {
        var x = val
        // line through 2 points
        let (xa, ya, xb, yb) = (scoring[0], scoring[1], scoring[2], scoring[3])
        // but x is clipped, xb>xa
        x = min(xb, max(xa, x))
        let a = (yb - ya)/(xb - xa)
        let b = (xb*ya - xa*yb)/(xb - xa)
        return a*x + b
    }

    func calculate() {
        if templateCount[2] == 0 { // no blue pixels, broken screenshot, wait
            return
        }
        
        if matchResults[5] > 0 {
            overlapK = calculateK(val: Double(matchResults[4]) / Double(matchResults[5]), scoring: scoringSystem.overlap)
        }
        roughnessK = calculateK(val: rippleSum / Double(rippleCount), scoring: scoringSystem.roughness)
        if templateCount[0] > 0 {
            redK = calculateK(val: Double(matchResults[0]) / Double(templateCount[0]), scoring: scoringSystem.red)
        }
        greenK = calculateK(val: Double(matchResults[1]) / Double(templateCount[1]), scoring: scoringSystem.green)
        blueK = calculateK(val: Double(matchResults[2]) / Double(templateCount[2]), scoring: scoringSystem.blue)
        oneMinusAlphaK = calculateK(val: Double(matchResults[3]) / Double(templateCount[3]), scoring: scoringSystem.oneMinusAlpha)
        
        strokeCountK = calculateK(val: Double(strokeCount), scoring: scoringSystem.strokeCount)
        strokeCountPlusOneK = calculateK(val: Double(strokeCount + 1), scoring: scoringSystem.strokeCount)
        calculateSummary()
    }
    
    var failExplanations = [
        "oneMinusAlphaK-falls": "Try to be more precise and match the expected image.",
        "overlapK-falls": "Try not to draw over your lines.",
        "roughnessK-falls": "Too rough. Try to draw fast steady lines, draw with your arm, not your wrist.",
        "roughnessK-grows": "Too smooth. Make your lines even rougher.",
        "strokeCountK-falls": "Try to use less strokes.",
        "strokeCountPlusOneK-falls": "You can't use many strokes on this step.",
    ]
    
    func addK(_ k: Double, _ p: Double, _ n: Double) -> (Double, Double) {
        if k >= 0 {
            return (p + k, n)
        } else {
            return (p, n + k)
        }
    }
    
    func findWhyFailed() {
        func comp(_ arr: [Double]) -> Double {
            return arr[3] >= arr[1] ? 1.0 : 0.0
        }
        let criteria: KeyValuePairs = [ // KeyValuePairs are ordered, dictionary is not
            "blueK": [blueK, comp(scoringSystem.blue)],
            "greenK": [greenK, comp(scoringSystem.green)],
            "oneMinusAlphaK": [oneMinusAlphaK, comp(scoringSystem.oneMinusAlpha)],
            "overlapK": [overlapK, comp(scoringSystem.overlap)],
            "roughnessK": [roughnessK, comp(scoringSystem.roughness)],
            "strokeCountK": [strokeCountK, comp(scoringSystem.strokeCount)],
            "strokeCountPlusOneK": [strokeCountPlusOneK, comp(scoringSystem.strokeCount)],
        ]
        
        var worstFail = 0.0
        var worstCriterion = "blueK"
        var grows = false
        criteria.forEach { key, val in
//            Swift.print("\(key) \(val[0])")
            if val[0] < worstFail {
                worstFail = val[0]
                grows = val[1] > 0
                worstCriterion = key
            }
        }
        self.whyFailed = failExplanations[worstCriterion + (grows ? "-grows" : "-falls")]
    }
    
    func calculateSummary() {
        findWhyFailed();
        var p = 0.0
        var n = 0.0
        [blueK, greenK, oneMinusAlphaK, overlapK, roughnessK].forEach {
            (p, n) = addK($0, p, n)
        }
        let (_, nPlusOne) = addK(strokeCountPlusOneK, p, n)
        (p, n) = addK(strokeCountK, p, n)
        positive = min(1, p)
        negative = matchResults.reduce(0, +) != 0 || p > 0 ? min(0, max(-1, n)) : 0 // don't show negative if nothing happened
        overall = max(0, positive + negative + redK)
        enoughBlueK = blueK >= scoringSystem.blue[4]
        passed = enoughBlueK && overall >= scoringSystem.passingScore
        // fixables: overlap, roughness ????????????????????????
        failed = !passed && min(1 + nPlusOne, 1 + negative) < scoringSystem.passingScore
    }
    
    func print() {
        Swift.print("b\(blueK.formatPercent(3)) r\(redK.formatPercent(3)) g\(greenK.formatPercent(3)) a\(oneMinusAlphaK.formatPercent(3)) ol\((Double(matchResults[4]) / Double(matchResults[5])).toString(3)) olK\(overlapK.formatPercent(3)) ro\((rippleSum/Double(rippleCount)).toString(3)) roK\(roughnessK.formatPercent(3)) sc\(strokeCount) scK\(strokeCountK.formatPercent(3)) pos\(positive.formatPercent(3)) neg\(negative.formatPercent(3)) ov\(overall.formatPercent(3)) p\(passed) f\(failed)")
    }
}
