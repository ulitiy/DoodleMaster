//
//  CourseListItemView.swift
//  ArtWorkout
//
//  Created by Aleksandr Ulitin on 08.02.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Amplitude_iOS

struct CourseListItemView: View {
    @ObservedObject var course: Course
    @State var openCourse: Bool?
    
    @ViewBuilder
    func destination(_ course: Course) -> some View {
        if course.tasks.count == 1 {
            LazyView(TaskView(task: course.tasks[0]))
        } else {
            TaskListView(course: course)
        }
    }
    
    var body: some View {
        NavigationLink(destination: destination(course), tag: true, selection: $openCourse) {
            VStack(spacing: 30) {
                ZStack {
                    CarouselView(count: course.tasks.count + 1) {
                        Image("thumbnails/\(course.path)/index").resizable().aspectRatio(contentMode: .fill)
                        ForEach(course.tasks, id: \.path) { task in
                            Image("thumbnails/\(task.path)").resizable().aspectRatio(contentMode: .fill)
                        }
                    }.aspectRatio(1, contentMode: .fit)
                    CourseProgressView(course: course)
                }
                Text(course.name)
                    .frame(maxHeight: 90, alignment: .top)
                    .font(.custom("Helvetica", size: 40))
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
            }
           .onTapGesture {                                     // comment this out to fix preview
               Amplitude.instance().logEvent("course_open", withEventProperties: [
                   "path": course.path,
                   "name": course.name,
                   "tasks_count": course.tasks.count,
                   "tasks_passed": course.tasksPassed,
               ])
               openCourse = true
           }
        }
    }
}

struct CourseListItemView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListItemView(course: handwriting)
            .background(Color.black)
            .previewLayout(.fixed(width: 290, height: 300))
    }
}
