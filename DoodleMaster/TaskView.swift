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
        let ts = TaskState(task: task)
        _taskState = StateObject(wrappedValue: ts)
    }
    
    var body: some View {
        ProgressView(value: taskState.currentResult.positive)
//        .padding()
        ZStack {
            WebViewWrapper(taskState: taskState)
            Text(String(format: "%.2f", taskState.currentResult.overall*100))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            CanvasContainerRepresentation(taskState: taskState)
            if taskState.passing {
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
