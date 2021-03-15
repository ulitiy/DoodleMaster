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
                ZStack {
                    Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color(hex:"5599ffff")!, Color(hex:"fff968ff")!, Color(hex:"ff5353ff")!]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: 70)
                        .mask(Rectangle().frame(height: 15)
                                .blur(radius: 10))
                        .opacity(0.5)
                    Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color(hex:"5599ffff")!, Color(hex:"fff968ff")!, Color(hex:"ff5353ff")!]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: 70)
                        .mask(Rectangle().frame(height: 8)
                                .blur(radius: 3))
                        .opacity(0.7)
                    Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color(hex:"cceeffff")!, Color(hex:"ffffddff")!, Color(hex:"ffccccff")!]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: 5)
                }.padding(-30)
                    
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
            .statusBar(hidden: true)
            .background(LinearGradient(gradient: Gradient(colors: [Color(white: 0.25), Color(white:0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            if course.firstTimePassed {
                CoursePassedView(course: course)
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(course: courses[0])
            .previewLayout(.fixed(width: 1366, height: 1024))
        TaskListView(course: courses[0])
            .previewLayout(.fixed(width: 1080, height: 810))
    }
}
