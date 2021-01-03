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

    init(task: Task) {
        // in order to use param with @StateObject
        let ts = TaskState(task: task)
        _taskState = StateObject(wrappedValue: ts)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ResultProgressView(positive: taskState.currentResult.positive, negative: taskState.currentResult.negative)
                ZStack {
                    WebViewWrapper(taskState: taskState).opacity((taskState.template != nil) ? 1 : 0)

                    CanvasWrapper(taskState: taskState)
                    
                    TaskOverlayView(taskState: taskState)
                }
            }
            
            if taskState.currentStep.showResult && taskState.passing && taskState.taskResult == nil {
                StepSuccessView(taskState: taskState)
            }
            if taskState.failing {
                StepFailView()
            }
            if taskState.taskResult != nil {
                TaskResultView(taskState: taskState)
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
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
