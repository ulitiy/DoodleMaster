//
//  Result.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 07.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

let neutral = [0.0, 0.0, 1, 0.0]
let oneStroke = [1.0, 0.0, 2.0, -1.0]
let smooth = [0.0, 0.3, 300.0, 0.0]
let punish = [0.0, 0.0, 0.01, -1]

struct ScoringSystem: Hashable {
    // xa, ya, xb, yb line coordinates, clamp x and interpolate
    var overlap = neutral
    var roughness = smooth
    var strokeCount = neutral

    var green = neutral
    var blue = [0.0, 0.0, 1.0, 1.0]
    var oneMinusAlpha = punish
    var attemptNumber = [1.0, 0.05, 2.0, 0.0]

    var minRed = 0.99
    var maxNegative = -0.2
    var weight = 1.0
}

class Result: ObservableObject {
    var matchResults: [UInt32] = [0, 0, 0, 0, 0, 0] { // r g b a ol pixelsDrawn
        didSet {
            calculate()
        }
    }
    
    var templateCount: [UInt32] = [0, 0, 0, 0]
    var strokeCount = 0 {
        didSet {
            calculate()
        }
    }
    var rippleSum = 0.0
    var ripplePageCount = 0
    // Add time
    // Add length

    var scoringSystem: ScoringSystem
    
    init(scoringSystem: ScoringSystem) {
        self.scoringSystem = scoringSystem
    }
    

    var overlapK = 0.0
    var roughnessK = 0.0
    var strokeCountK = 0.0
    var strokeCountPlusOneK = 0.0
    var red = 0.0 // not redk
    var greenK = 0.0
    var blueK = 0.0
    var oneMinusAlphaK = 0.0
    var enoughRed = false
    var attemptNumber = 1
    var attemptK = 0.0

    @Published var overall = 0.0
    @Published var passed = false
    @Published var failed = false
    @Published var positive = 0.0
    @Published var negative = 0.0
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
        if templateCount[0] == 0 { // no red pixels, broken screenshot, wait
            return
        }
        red = Double(matchResults[0]) / Double(templateCount[0])
        blueK = calculateK(val: Double(matchResults[2]) / Double(templateCount[2]), scoring: scoringSystem.blue)
        greenK = calculateK(val: Double(matchResults[1]) / Double(templateCount[1]), scoring: scoringSystem.green)
        oneMinusAlphaK = calculateK(val: Double(matchResults[3]) / Double(templateCount[3]), scoring: scoringSystem.oneMinusAlpha)

        if matchResults[5] > 0 {
            overlapK = calculateK(val: Double(matchResults[4]) / Double(matchResults[5]), scoring: scoringSystem.overlap)
        }
        roughnessK = calculateK(val: rippleSum / Double(ripplePageCount), scoring: scoringSystem.roughness)
        
        strokeCountK = calculateK(val: Double(strokeCount), scoring: scoringSystem.strokeCount)
        strokeCountPlusOneK = calculateK(val: Double(strokeCount + 1), scoring: scoringSystem.strokeCount)
        attemptK = calculateK(val: Double(attemptNumber), scoring: scoringSystem.attemptNumber)
        calculateSummary()
    }
    
    var failExplanations = [
        "oneMinusAlphaK-falls": "Try to be more precise and match the expected image.",
        "overlapK-falls": "Try not to draw over your lines.",
        "roughnessK-falls": "Too rough. Try to draw fast steady lines, draw with your arm, not your wrist.",
        "roughnessK-grows": "Too smooth. Make your lines even rougher.",
        "strokeCountK-falls": "Try to use minimum amount of strokes to complete this step.",
        "strokeCountPlusOneK-falls": "Try to use minimum amount of strokes to complete this step.",
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
        [blueK, greenK, oneMinusAlphaK, overlapK, roughnessK, attemptK].forEach {
            (p, n) = addK($0, p, n)
        }
        let (_, nPlusOne) = addK(strokeCountPlusOneK, p, n)
        (p, n) = addK(strokeCountK, p, n)
        let red = Double(matchResults[0]) / Double(templateCount[0])
        positive = p
        negative = (matchResults.reduce(0, +) != 0 || p > 0) ? min(0, max(-1, n)) : 0 // don't show negative if nothing happened
        overall = max(0, positive + negative)
        enoughRed = red >= scoringSystem.minRed
        passed = enoughRed && negative >= scoringSystem.maxNegative
        failed = !passed && min(nPlusOne, negative) < scoringSystem.maxNegative
    }
    
    func print() {
        Swift.print(toString())
    }
    
    func toString() -> String {
        return "r\t\t\(red.formatPercent())\nb\t\t\(blueK.formatPercent())\ng\t\t\(greenK.formatPercent())\na\t\t\(oneMinusAlphaK.formatPercent())\nol\t\t\((Double(matchResults[4]) / Double(matchResults[5])).toString(3))\nolK\t\t\(overlapK.formatPercent())\nro\t\t\((rippleSum/Double(ripplePageCount)).toString())\nroK\t\t\(roughnessK.formatPercent())\nsc\t\t\(strokeCount)\nscK\t\(strokeCountK.formatPercent())\nan\t\t\(attemptNumber)\nanK\t\(attemptK.formatPercent())\npos\t\(positive.formatPercent())\nneg\t\(negative.formatPercent())\nov\t\t\(overall.formatPercent())\ner\t\t\(enoughRed)\np\t\t\(passed)\nf\t\t\(failed)\nmr\t\t\(matchResults)\ntc\t\t\(templateCount)"
    }
    
    func toDictionary() -> Dictionary<String, Double> {
        let ro = ripplePageCount > 0 ? rippleSum / Double(ripplePageCount) : 0
        return [
            "red": red,
            "greenK": greenK,
            "blueK": blueK,
            "oneMinusAlphaK": oneMinusAlphaK,
            "roughness": ro,
            "roughnessK": roughnessK,
            "overlapK": overlapK,
            "strokeCountK": strokeCountK,
            "positive": positive,
            "negative": negative,
            "overall": overall,
        ]
    }
}
