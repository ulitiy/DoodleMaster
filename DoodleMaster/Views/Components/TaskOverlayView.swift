//
//  TaskOverlayView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskOverlayView: View {
    @State var showCheckmark = false
    @ObservedObject var taskState: TaskState

    var body: some View {
        ZStack {
            // top left
            TaskMenuView(taskState: taskState)
            
            
            // top right
            VStack(alignment: .trailing, spacing: 10) {
                Text("\(taskState.stepNumber) / \(taskState.task.steps.count)")
                    .font(.custom("LucidaGrande", size: 30))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                if showCheckmark {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 100.0, weight: .light))
                        .transition(AnyTransition.opacity.combined(with: .scale).animation(.interpolatingSpring(stiffness: 1000, damping: 15)))
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()

            // bottom left
            if taskState.whyFailed != nil {
                WhyFailedView(whyFailed: taskState.whyFailed!)
            }

            #if DEBUG
            if taskState.debugTemplate {
                Text(taskState.currentResult.toString())
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
                    .allowsHitTesting(false)
            }
            #endif
        }
        .onReceive(taskState.$passing, perform: { val in
            guard val, !taskState.currentStep.showResult else { return }
            showCheckmark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showCheckmark = false
            }
        })
    }
}

struct TaskOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TaskOverlayView(taskState: TaskState(task: Task(name: "Line", path: "Basics/1/1", steps: [TaskStep()])))
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
