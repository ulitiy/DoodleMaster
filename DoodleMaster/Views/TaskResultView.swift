//
//  TaskResultView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 01.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskResultView: View {
    @ObservedObject var taskState: TaskState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 150.0, weight: .light))
                    .padding(.bottom, 10)
                Text("Task passed")
                    .font(.system(size: 70.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .padding(.bottom, 30)
                Text("\(taskState.taskResult!.overall.formatPercent()) %")
                    .font(.system(size: 70.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .padding(30)
                ResultDetailsView(result: taskState.taskResult!, time: taskState.dateStarted.timeIntervalSinceNow)
                    .padding(30)
            }.padding(.bottom, 150)
            ZStack {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Text("OK")
                        .font(.system(size: 35))
                        .padding(.horizontal, 60)
                        .padding(.vertical, 25)
                        .overlay(RoundedRectangle(cornerRadius: 500).stroke(lineWidth: 4))
                    .foregroundColor(Color(hex: "303b96ff"))
                }
            }
            .padding(60)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .zIndex(2)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
    }
}

struct TaskResultView_Previews: PreviewProvider {
    static func makeTaskState() -> TaskState {
        let ts = TaskState(task: Task(name: "", path: "", steps: [TaskStep()]))
        let r = Result(scoringSystem: ScoringSystem())
        r.overall = 0.9876
        r.blueK = 0.98765
        r.oneMinusAlphaK = -0.1234
        r.overlapK = -0.1
        r.roughnessK = -0.1
        r.strokeCountK = -0.1
        ts.dateStarted = Date() + 100
        ts.taskResult = r
        return ts
    }
    
    static var previews: some View {
        TaskResultView(taskState: makeTaskState())
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
