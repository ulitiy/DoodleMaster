//
//  StepSuccessView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 01.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct StepSuccessView: View {
    @ObservedObject var taskState: TaskState
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack(spacing: 60) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .font(.system(size: 150.0, weight: .light))
                Text("\(taskState.currentResult.overall.formatPercent()) %")
                    .font(.custom("LucidaGrande", size: 70.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                ResultDetailsView(result: taskState.currentResult, time: nil)
            }.padding(.bottom, 150)
            ZStack {
                Button(action: { taskState.switchNextStep() }) {
                    Text("OK")
                        .font(.custom("LucidaGrande", size: 35))
                        .padding(.horizontal, 60)
                        .padding(.vertical, 25)
                        .overlay(RoundedRectangle(cornerRadius: 500).stroke(lineWidth: 4))
                    .foregroundColor(Color(hex: "303b96ff"))
                }
            }
            .padding(60)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .zIndex(1)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
    }
}

struct StepSuccessView_Previews: PreviewProvider {
    static func makeTaskState() -> TaskState {
        let ts = TaskState(task: Task(name: "", path: "", steps: [TaskStep()]))
        let r = ts.currentResult!
        r.overall = 0.9876
        r.blueK = 0.98765
        r.oneMinusAlphaK = -0.1234
        r.overlapK = -0.1
        r.roughnessK = -0.1
        r.strokeCountK = -0.1
        return ts
    }
    
    static var previews: some View {
        StepSuccessView(taskState: makeTaskState())
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
