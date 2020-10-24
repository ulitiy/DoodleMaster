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
        ZStack {
            WebViewWrapper()
            Text(String(format: "%.2f", taskState.currentResult.overall*100)).position(x: 100.0, y: 100.0)
            CanvasContainerRepresentation(taskState: taskState)
        }
        .navigationBarHidden(true)
        .navigationBarTitle(Text(""))
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
//        .prefersHomeIndicatorAutoHidden(true)
        
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1")).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
