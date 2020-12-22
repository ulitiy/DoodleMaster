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
    
    var body: some View {
        Text("Match: \(result.blueK.formatPercent(".2"))")
            .foregroundColor(.green)
        Text("Deviation: \(result.oneMinusAlphaK.formatPercent(".2"))")
            .foregroundColor(.red)
        Text("Roughness: \(result.roughnessK.formatPercent(".2"))")
            .foregroundColor(.red)
        Text("Overlap: \(result.overlapK.formatPercent(".2"))")
            .foregroundColor(.red)
        Text("Stroke count: \(result.strokeCountK.formatPercent(".2"))")
            .foregroundColor(.red)
    }
}

struct TaskView: View {
    @StateObject var taskState: TaskState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showRestartAlert = false
    @State private var showBackToMenuAlert = false

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

            Text(formatPercent(taskState.currentResult.positive))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            Text("\(taskState.stepNumber)/\(taskState.task.steps.count)")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()
            
            CanvasContainerRepresentation(taskState: taskState)
            
            HStack {
                Button(action: { showBackToMenuAlert.toggle() }) {
                    Image(systemName: "chevron.left.circle")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
                .alert(isPresented: $showBackToMenuAlert) {
                    Alert(title: Text("Are you sure want to return to menu?"), primaryButton: .default(Text("Yes"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .default(Text("Cancel")))
                }
                Button(action: { showRestartAlert.toggle() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
                .alert(isPresented: $showRestartAlert) {
                    Alert(title: Text("Are you sure want to restart the task?"), primaryButton: .default(Text("Yes"), action: { taskState.restartTask() }), secondaryButton: .default(Text("Cancel")))
                }
                Button(action: { taskState.skipAnimation = true }) {
                    Image(systemName: "forward")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
                Button(action: { taskState.passStep() }) {
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()

            if taskState.currentStep.showResult && taskState.passing && taskState.taskResult == nil {
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
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1", steps: [TaskStep()])).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
