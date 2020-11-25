//
//  Result.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 07.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

struct ScoringSystem: Hashable {
    // xa, ya, xb, yb line coordinates, clamp x and interpolate
    var overlap = [0.07, 0.0, 0.15, 0.0]
    var roughness = [1.0, 0.0, 4.0, 0.0] // 0-1 very smooth 1-3 okish 3+ bad
    var strokeCount = [4.0, 0.0, 8.0, 0.0]

    var red = [0.0, 0.0, 1.0, 0.0] // debug
//    var red = [0.9699, 0.0, 0.97, -1] // necessary, sharp line
    var green = [0.0, 0.0, 1.0, 0.0] // neutral
    var blue = [0.0, 0.0, 1.0, 1.0] // good, match
    var oneMinusAlpha = [0.0, 0.0, 0.01, -1] // bad, deviation

    var passingScore = 0.3 // debug
//    var passingScore = 0.9
}

class Result: ObservableObject {
    @Published var matchResults: [UInt32] = [0, 0, 0, 0, 0, 0] {
        didSet {
            calculate()
        }
    }
    
    @Published var templateCount: [UInt32] = [0, 0, 0, 0]
    @Published var strokeCount = 0
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

    @Published var overlapK = 0.0
    @Published var roughnessK = 0.0
    @Published var strokeCountK = 0.0
    @Published var redK = 0.0
    @Published var greenK = 0.0
    @Published var blueK = 0.0
    @Published var oneMinusAlphaK = 0.0
    
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
        if templateCount[1] == 0 {
            
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
        
        strokeCountK = calculateK(val: Double(strokeCount+1), scoring: scoringSystem.strokeCount)
        // Why +1? It doesn't recalculate when canvas.data.elements.count changes because it doesn't redraw
        calculateSummary()
    }
    
    func calculateSummary() {
        positive = min(1, blueK)
        negative = min(0, max(-1, oneMinusAlphaK + overlapK + strokeCountK))
        overall = max(0, positive + negative + roughnessK + redK)
        // green doesn't count anywhere
        passed = overall > scoringSystem.passingScore
        failed = 1 + negative < scoringSystem.passingScore
    }
    
    func print() {
        Swift.print("b\(Int(100.0*blueK)) r\(Int(100.0*redK)) g\(Int(100.0*greenK)) a\(Int(100.0*oneMinusAlphaK)) ol\(Int(100.0*overlapK)) roK\(Int(100.0*roughnessK)) ro\(rippleSum/Double(rippleCount)) sc\(Int(100.0*strokeCountK)) neg\(negative)")
    }
}
