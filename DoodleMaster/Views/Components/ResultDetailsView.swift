//
//  ResultDetailsView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 01.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct ResultDetailsView: View {
    var result: Result
    var time: TimeInterval?
    
    @ViewBuilder
    func formatRow(name: String, val: Double) -> some View {
        if abs(val).formatPercent() != "0" {
            HStack {
                Text(name)
                    .kerning(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                Text("\(val > 0 ? "+" : "")\(val.formatPercent()) %")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(val >= 0 ? .green : .red)
            }
        }
    }
    
    func getTime() -> String {
        let f = DateComponentsFormatter()
        f.zeroFormattingBehavior = .pad
        f.allowedUnits = [.minute, .second]
        return f.string(from: abs(time!))!
    }
    
    var body: some View {
        VStack(spacing: 20) {
            formatRow(name: "Match", val: result.blueK)
            formatRow(name: "Deviation", val: result.oneMinusAlphaK)
            formatRow(name: "Smoothness bonus", val: result.roughnessK)
            formatRow(name: "Stroke overlap", val: result.overlapK)
            formatRow(name: "Stroke count", val: result.strokeCountK)
            if time != nil {
                HStack {
                    Text("Time")
                        .kerning(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                    Text(getTime())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 400)
        .font(.custom("LucidaGrande", size: 26))
    }
}

struct ResultDetailsView_Previews: PreviewProvider {
    static func makeResult() -> Result {
        let r = Result(scoringSystem: ScoringSystem())
        r.blueK = 0.98765
        r.oneMinusAlphaK = -0.1234
        return r
    }
    
    static var previews: some View {
        ResultDetailsView(result: makeResult(), time: 200)
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
