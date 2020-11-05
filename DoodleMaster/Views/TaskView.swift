//
//  ContentView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    @StateObject var taskState: TaskState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(task: Task) {
        // in order to use param with @StateObject
        let ts = TaskState(task: task)
        _taskState = StateObject(wrappedValue: ts)
    }
    
    func formatPercent(_ res: Double) -> String {
        return String(format: "%.2f", res*100)
    }
    
    var taskResult: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack {
                Text("Task passed!\n")
                .font(.system(size: 100.0))
                Divider()
                Text("Match: \(formatPercent(taskState.taskResult!.blueK))")
                    .foregroundColor(.green)
                Text("Deviation: \(formatPercent(taskState.taskResult!.oneMinusAlphaK))")
                    .foregroundColor(.red)
                Text("Overlap: \(formatPercent(taskState.taskResult!.overlapK))")
                    .foregroundColor(.red)
                Text("Stroke count: \(formatPercent(taskState.taskResult!.strokeCountK))")
                    .foregroundColor(.red)
                Text(String(format: "%.2f", taskState.taskResult!.overall*100))
                .font(.system(size: 100.0))
                .foregroundColor(.blue)
                Divider()
                Button("OK", action: {
                    self.presentationMode.wrappedValue.dismiss()
                }).font(.system(size: 100.0))
            }
        }
        .zIndex(2)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
    }
    
    var body: some View {
        ProgressView(value: taskState.currentResult.positive)
        ZStack {
            WebViewWrapper(taskState: taskState).opacity((taskState.template != nil) ? 1 : 0)
            .animation(Animation.linear(duration: 0).delay(0.1))

            Text(String(format: "%.2f", taskState.currentResult.overall*100))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            Text("\(taskState.stepNumber)/\(taskState.task.stepCount)")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()

            CanvasContainerRepresentation(taskState: taskState)

            if taskState.passing && taskState.taskResult == nil {
                ZStack {
                    Rectangle().fill(Color.white)
                    Text("✅").font(.system(size: 100.0))
                }
                .zIndex(1)
                .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
            }
            if taskState.failing {
                ZStack {
                    Rectangle().fill(Color.white)
                    Text("❌").font(.system(size: 100.0))
                }
                .zIndex(1)
                .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
            }
            if taskState.taskResult != nil {
                taskResult
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle(Text(""))
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1")).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
