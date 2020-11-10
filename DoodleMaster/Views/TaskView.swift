//
//  ContentView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct ResultDetailsView: View {
    var result: Result
    
    func formatPercent(_ res: Double) -> String {
        return String(format: "%.2f", res*100)
    }
    
    var body: some View {
        Text("Match: \(formatPercent(result.blueK))")
            .foregroundColor(.green)
        Text("Deviation: \(formatPercent(result.oneMinusAlphaK))")
            .foregroundColor(.red)
        Text("Roughness: \(formatPercent(result.roughnessK))")
            .foregroundColor(.red)
        Text("Overlap: \(formatPercent(result.overlapK))")
            .foregroundColor(.red)
        Text("Stroke count: \(formatPercent(result.strokeCountK))")
            .foregroundColor(.red)
    }
}

struct TaskView: View {
    @StateObject var taskState: TaskState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showRestartAlert = false
    
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
                ResultDetailsView(result: taskState.taskResult!)
                Text(formatPercent(taskState.taskResult!.overall))
                .font(.system(size: 100.0))
                .foregroundColor(.green)
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
        ResultProgressView(positive: taskState.currentResult.positive, negative: taskState.currentResult.negative)
        ZStack {
            WebViewWrapper(taskState: taskState).opacity((taskState.template != nil) ? 1 : 0)
//            .animation(Animation.linear(duration: 0).delay(0.1)) // delays both ways, unacceptable

            Text(formatPercent(taskState.currentResult.overall))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            Text("\(taskState.stepNumber)/\(taskState.task.stepCount)")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()

            CanvasContainerRepresentation(taskState: taskState)
            
            Group {
                Button(action: { showRestartAlert.toggle() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()

            if taskState.passing && taskState.taskResult == nil {
                ZStack {
                    Rectangle().fill(Color.white)
                    VStack {
                        Text("✅").font(.system(size: 100.0))
                        Divider()
                        ResultDetailsView(result: taskState.currentResult)
                        Text(formatPercent(taskState.currentResult.overall))
                        .font(.system(size: 100.0))
                        .foregroundColor(.green)
                    }
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
        .alert(isPresented: $showRestartAlert) {
            Alert(title: Text("Are you sure want to restart the task?"), primaryButton: .default(Text("Yes"), action: { taskState.restartTask() }), secondaryButton: .default(Text("Cancel")))
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1")).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
