//
//  ContentView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    var task: Task
    @StateObject var result = Result()

    var body: some View {
        ZStack {
            Image("Courses/\(task.path)/1.step")
                .resizable()
                .aspectRatio(contentMode: .fit)
            CanvasContainerRepresentation(task: task, result: result)
            Text("\(result.overall)")
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView(task: Task(name: "Line", path: "Basics/1/1")).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
