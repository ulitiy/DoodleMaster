//
//  ContentView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Amplitude_iOS

struct TaskView: View {
    @StateObject var taskState: TaskState

    init(task: Task) {
        // in order to use param with @StateObject
        let ts = TaskState(task: task)
        _taskState = StateObject(wrappedValue: ts)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ResultProgressView(positive: taskState.currentResult.blueK, negative: taskState.currentResult.oneMinusAlphaK) // otherwise we get >100%
                ZStack {
                    TemplateWebViewWrapper(taskState: taskState).opacity(0)
                    WebViewWrapper(taskState: taskState)
                    
                    if taskState.whyFailed != nil {
                        WhyFailedView(whyFailed: taskState.whyFailed!)
                    }

                    CanvasWrapper(taskState: taskState)
                    
                    TaskOverlayView(taskState: taskState)
                }
            }
            
            if taskState.currentStep.showResult && taskState.passing && taskState.taskResult == nil {
                StepResultView(taskState: taskState)
            }
            if taskState.failing {
                StepFailView()
            }
            if taskState.taskResult != nil {
                TaskResultView(taskState: taskState)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
        .onAppear() {
            Amplitude.instance().logEvent("task_open", withEventProperties: [
                "path": taskState.task.path,
                "name": taskState.task.name,
                "result": taskState.task.result,
            ])
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1"))
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
