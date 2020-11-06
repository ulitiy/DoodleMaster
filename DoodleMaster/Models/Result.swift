//
//  Result.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 07.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

struct ScoringSystem: Hashable {
    // xa, ya, xb, yb clamp x and interpolate
    var overlap = [0.07, 0.0, 0.15, -1.0]
    var curvature = [0.0, 0.0, 1.0, 0]
    var strokeCount = [4.0, 0.0, 8.0, -1.0]

    var red = [0.9699, 0.0, 0.97, 0.0] // necessary, sharp line // -1, debugging
    var green = [0.0, 0.0, 1.0, 0.0] // neutral
    var blue = [0.0, 0.0, 1.0, 1.0] // good, match
    var oneMinusAlpha = [0.0, 0.0, 0.005, -1] // bad, deviation

    var passingScore = 0.3 // to debug
}

class Result: ObservableObject {
    @Published var matchResults: [UInt32] = [0, 0, 0, 0, 0, 0] {
        didSet {
            calculate()
        }
    }
    
    @Published var templateCount: [UInt32] = [0, 0, 0, 0]
    @Published var strokeCount = 0
    @Published var curvature = 0
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
    @Published var curvatureK = 0.0
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
//        curvatureK = calculateK(val: matchResults[4] / matchResults[5], scoring: scoringSystem.curvature)
//        strokeCountK = calculateK(val: matchResults[4] / matchResults[5], scoring: scoringSystem.strokeCount)
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
        negative = max(-1, oneMinusAlphaK + overlapK + curvatureK + strokeCountK)
        overall = max(0, positive + negative)
        // green doesn't count anywhere
        // red doesn't count into overall because it's not a punishment, it's a requirement
        passed = overall + redK > scoringSystem.passingScore
        failed = 1 + negative < scoringSystem.passingScore
        // redK isn't a punishment, it's just a lack of stimulation
//        print("b\(Int(100.0*blueK)) r\(Int(100.0*redK)) g\(Int(100.0*greenK)) a\(Int(100.0*oneMinusAlphaK)) ol\(Int(100.0*overlapK)) sc\(Int(100.0*strokeCountK))")
    }
}