//
//  StepSuccessView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 01.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct StepResultView: View {
    var taskState: TaskState // not observable to keep the values intact
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack(spacing: 60) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .font(.system(size: 150.0, weight: .light))
                HStack(alignment: .bottom) {
                    Text("\(taskState.currentResult!.overall.formatScore())")
                        .font(Font.custom("Montserrat-Medium", size: 70.0))
                        .foregroundColor(Color(hex: "303b96ff"))

                    Text("/ 1350")
                        .foregroundColor(.gray)
                        .font(.custom("Helvetica", size: 25))
                        .padding(.bottom, 13)
                }
                .padding(.leading, 90)
                ResultDetailsView(result: taskState.currentResult, time: nil)
            }.padding(.bottom, 150)
            ZStack {
                Button(action: { taskState.switchNextStep() }) {
                    Text("OK")
                        .font(.custom("Helvetica", size: 35))
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
        let ts = TaskState(task: Task(name: "", path: ""))
        let r = ts.currentResult!
        r.overall = 1.210
        r.blueK = 0.98765
        r.roughnessK = 0.1
        return ts
    }
    
    static var previews: some View {
        StepResultView(taskState: makeTaskState())
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
