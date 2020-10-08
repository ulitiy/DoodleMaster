//
//  Result.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 07.10.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

class Result: ObservableObject {
    @Published var matchResults: [UInt32] = [0, 0, 0, 0, 0, 0] {
        didSet {
            calculate()
        }
    }
    
    @Published var templateCount: [UInt32] = [0, 0, 0, 0]
    @Published var strokeCount = 0
    @Published var curvature = 0

    @Published var scoringSystem = ScoringSystem()
    
    @Published var overall = 0.0
    @Published var positive = 0.0
    @Published var negative = 0.0

    @Published var overlapK = 0.0
    @Published var curvatureK = 0.0
    @Published var strokeCountK = 0.0
    @Published var redK = 1.0
    @Published var greenK = 0.0
    @Published var blueK = 0.0
    @Published var oneMinusAlphaK = 0.0
    
    func calculateK(val: Double = 0, scoring: [Double] = [0.0, 0.0, 1.0, 0.0]) -> Double {
        var x = val
        let (xa, ya, xb, yb) = (scoring[0], scoring[1], scoring[2], scoring[3])
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
        if templateCount[3] > 0 {
            oneMinusAlphaK = calculateK(val: Double(matchResults[3]) / Double(templateCount[3]), scoring: scoringSystem.oneMinusAlpha)
        }
        positive = min(1, greenK)
        negative = max(-1, overlapK + curvatureK + strokeCountK + blueK + oneMinusAlphaK + redK)
        overall = max(0, positive + negative)
        print(positive)
        print(negative)
        print("----------")
    }
}
