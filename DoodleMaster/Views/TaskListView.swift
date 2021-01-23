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
        ScrollView(.vertical) {
            CourseDescriptionView(course: course)
            Divider().frame(height: 4).background(Color(hex: "303b96ff"))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 30)],
                      alignment: .center, spacing: 30) {
                ForEach(course.tasks, id: \.path) {task in
                    NavigationLink(destination: LazyView(TaskView(task: task))) {
                        Image("thumbnails/\(task.path)").resizable().aspectRatio(1,contentMode: .fit)
                            .cornerRadius(30)
                            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(hex: "303b96ff")!, lineWidth: 4))
                            .overlay(
                                Text(task.name)
                                    .font(.custom("LucidaGrande", size: 20))
                                    .foregroundColor(Color(hex: "303b96ff"))
                                    .shadow(color: .white, radius: 2)
                                    .shadow(color: .white, radius: 2)
                                    .shadow(color: .white, radius: 2)
                                    .padding(10)
                                , alignment: .bottom)
                            .overlay(
                                Group {
                                    if task.result >= 0 {
                                        Text("\(task.result.formatPercent()) %")
                                            .font(.custom("LucidaGrande", size: 16))
                                            .foregroundColor(Color(hex: "303b96ff"))
                                            .shadow(color: .white, radius: 2)
                                            .shadow(color: .white, radius: 2)
                                            .shadow(color: .white, radius: 2)
                                            .padding(20)
                                    }
                                }
                                , alignment: .topTrailing)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .padding(40)
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
