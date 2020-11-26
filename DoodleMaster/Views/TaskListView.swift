//
//  TaskListView.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

let multistep = TaskStep(clearBefore: false, showResult: false)
let lineworkStep = TaskStep(scoringSystem: ScoringSystem(
    overlap: [0.07, 0.0, 0.15, -0.8],
    roughness: [2.0, 0.0, 5.0, -0.3],
    strokeCount: [5.0, 0.0, 12.0, -1.0],
    oneMinusAlpha: [0.0, 0.0, 0.005, -1]
))

struct TaskListView: View {
    let tasks = [
        Task(name: "Basics", path: "Basics/1/1", steps: Array.init(repeating: lineworkStep, count: 6)),
        Task(name: "Loomis", path: "Basics/1/2", steps: Array.init(repeating: multistep, count: 8)),
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 65) {
                ForEach(tasks, id: \.self) {task in
                    NavigationLink(destination: LazyView(TaskView(task: task))) {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 12)
                                .foregroundColor(Color(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                                .frame(width: 236, height: 236)
                            Circle()
                                .frame(width: 200, height: 200, alignment: .leading)
                            Text(task.name)
                                .font(.system(size: 50))
                                .foregroundColor(Color.white)
                        }
                    }
                }
            }
            .padding(.leading, 65)
            .frame(minHeight: 0, maxHeight: .infinity)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView().previewLayout(.fixed(width: 1366, height: 1024))
    }
}
#endif
