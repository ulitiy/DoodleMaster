//
//  CourseListView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseListView: View {
    @StateObject var courseListState = globalState
    
    @ViewBuilder
    func destination(_ course: Course) -> some View {
        if course.tasks.count == 1 {
            LazyView(TaskView(task: course.tasks[0]))
        } else {
            TaskListView(course: course)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 80)],
                      alignment: .center, spacing: 80) {
                ForEach(courseListState.courses, id: \.path) { course in
                    NavigationLink(destination: destination(course)) {
                        VStack {
                            CarouselView(count: course.tasks.count + 1) {
                                Image("thumbnails/\(course.path)/index").resizable().aspectRatio(contentMode: .fill)
                                ForEach(course.tasks, id: \.path) { task in
                                    Image("thumbnails/\(task.path)").resizable().aspectRatio(contentMode: .fill)
                                }
                            }.aspectRatio(1,contentMode: .fit)
                            Text(course.name)
                                .frame(maxHeight: 50)
                                .font(.custom("LucidaGrande", size: 50))
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)
                                .foregroundColor(Color(hex: "303b96ff"))
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.padding(50)
        }
        .navigationTitle("Courses")
        .navigationBarHidden(true)
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
            .previewDevice("iPad (8th generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
