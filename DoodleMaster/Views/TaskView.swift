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
    @State private var showRestartAlert = false
    @State private var showBackToMenuAlert = false

    init(task: Task) {
        // in order to use param with @StateObject
        let ts = TaskState(task: task)
        _taskState = StateObject(wrappedValue: ts)
    }
    
    var overlay: some View {
        ZStack {
            #if DEBUG
            Text(taskState.currentResult.positive.formatPercent())
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            #endif
            Text("\(taskState.stepNumber) / \(taskState.task.steps.count)")
                .font(.system(size: 30))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))//
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()
            .alert(isPresented: $showBackToMenuAlert) {
                Alert(title: Text("Are you sure want to return to menu?"), primaryButton: .default(Text("Yes"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .default(Text("Cancel")))
            }
            if taskState.whyFailed != nil {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 40))
                    Text(taskState.whyFailed!)
                        .font(.system(size: 25))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))//
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading).padding()
            }
            HStack {
                Menu {
                    Button("Restart step", action: { taskState.failStep() })
                    Button("Restart task", action: { showRestartAlert.toggle() })
                    Toggle("Skip animations", isOn: $taskState.skipAnimation)
                    Button("Exit to menu", action: { showBackToMenuAlert.toggle() })
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50, weight: .heavy))
                }

                #if DEBUG
                Button(action: { taskState.passStep() }) {
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
                #endif
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .alert(isPresented: $showRestartAlert) {
                Alert(title: Text("Are you sure want to restart the task?"), primaryButton: .default(Text("Yes"), action: { taskState.restartTask() }), secondaryButton: .default(Text("Cancel")))
            }
        }
    }
    
    var taskResult: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack {
                Text("Task passed!")
                .font(.system(size: 100.0))
                Divider()
                ResultDetailsView(result: taskState.taskResult!)
                Text(taskState.taskResult!.overall.formatPercent())
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
    
    var stepFail: some View {
        ZStack {
            Rectangle().fill(Color.white)
            Image(systemName: "xmark").foregroundColor(.red).font(.system(size: 130.0, weight: .bold))
        }
        .zIndex(1)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))

    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ResultProgressView(positive: taskState.currentResult.positive, negative: taskState.currentResult.negative)
                ZStack {
                    WebViewWrapper(taskState: taskState).opacity((taskState.template != nil) ? 1 : 0)

                    CanvasContainerRepresentation(taskState: taskState)
                    
                    overlay
                }
            }
            
            if taskState.currentStep.showResult && taskState.passing && taskState.taskResult == nil {
                StepSuccessView(taskState: taskState)
            }
            if taskState.failing {
                stepFail
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
        TaskView(task: Task(name: "Line", path: "Basics/1/1", steps: [TaskStep()]))
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
