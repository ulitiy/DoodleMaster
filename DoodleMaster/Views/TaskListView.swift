//
//  TaskListView.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI
import Amplitude_iOS

struct TaskListView: View {
    @ObservedObject var course: Course
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                CourseDescriptionView(course: course)
                Divider().frame(height: 4).background(Color(hex: "303b96ff"))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 30)],
                          alignment: .center, spacing: 30) {
                    ForEach(course.tasks, id: \.path) {task in
                        TaskListItemView(task: task)
                    }
                }
                .padding(40)
                .frame(minHeight: 0, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
            if course.firstTimePassed {
                CoursePassedView(course: course)
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(course: courses[0]).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
