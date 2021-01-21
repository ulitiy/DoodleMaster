//
//  TaskListView.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var course: Course
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 65) {
                ForEach(course.tasks, id: \.path) {task in
                    NavigationLink(destination: LazyView(TaskView(task: task))) {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 12)
                                    .foregroundColor(Color(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                                    .frame(width: 236, height: 236)
                                Circle()
                                    .frame(width: 200, height: 200, alignment: .leading)
                                Text(task.name)
                                    .font(.custom("LucidaGrande", size: 50))
                                    .foregroundColor(Color.white)
                            }
                            Text(String(format: "%.2f", task.result * 100))
                                .font(.custom("LucidaGrande", size: 30))
                        }
                    }
                }
            }
            .padding(.leading, 65)
            .frame(minHeight: 0, maxHeight: .infinity)
        }
        .navigationBarTitle(course.name, displayMode: .inline)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(course: courses[0]).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
