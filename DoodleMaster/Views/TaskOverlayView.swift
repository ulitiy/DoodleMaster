//
//  TaskOverlayView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskOverlayView: View {
    @ObservedObject var taskState: TaskState

    var body: some View {
        ZStack {
            // top left
            TaskMenuView(taskState: taskState)
            
            // top center
            #if DEBUG
            Text(taskState.currentResult.positive.formatPercent())
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            #endif
            
            // top right
            Text("\(taskState.stepNumber) / \(taskState.task.steps.count)")
                .font(.custom("LucidaGrande", size: 30))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))//
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()
            
            // bottom left
            if taskState.whyFailed != nil {
                WhyFailedView(whyFailed: taskState.whyFailed!)
            }
        }
    }
}

struct TaskOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TaskOverlayView(taskState: TaskState(task: Task(name: "Line", path: "Basics/1/1", steps: [TaskStep()])))
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
