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
    func formatRow(name: String, val: Double, max: Int) -> some View {
        if abs(val).formatPercent() != "0" {
            HStack {
                Text(name)
                    .kerning(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.gray)
                    .font(.custom("LucidaGrande", size: 25))
                Text("\((val*1000).rounded().toString())")
                    .frame(maxWidth: 70, alignment: .center)
                    .foregroundColor(Color(hue: 0.4 * val * 1000 / Double(max), saturation: 1, brightness: 0.75))
                    .font(.custom("LucidaGrande", size: 25))
                Text("/")
                    .foregroundColor(.gray)
                    .font(.custom("LucidaGrande", size: 25))
                Text(String(max))
                    .frame(maxWidth: 70, alignment: .center)
                    .foregroundColor(.gray)
                    .font(.custom("LucidaGrande", size: 25))
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
            formatRow(name: "Match", val: result.blueK + result.oneMinusAlphaK, max: 1000)
            formatRow(name: "Smoothness", val: result.roughnessK, max: 300)
            if time != nil {
                HStack {
                    Text("Time")
                        .kerning(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                    Text(getTime())
                        .frame(maxWidth: 170, alignment: .center)
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
        r.roughnessK = 0.1234
        return r
    }
    
    static var previews: some View {
        ResultDetailsView(result: makeResult(), time: 200)
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
