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
            VStack {
                ZStack {
                    CarouselView(count: course.tasks.count + 1) {
                        Image("thumbnails/\(course.path)/index").resizable().aspectRatio(contentMode: .fill)
                        ForEach(course.tasks, id: \.path) { task in
                            Image("thumbnails/\(task.path)").resizable().aspectRatio(contentMode: .fill)
                        }
                    }.aspectRatio(1, contentMode: .fit)
                    ZStack {
                        if course.percentPassed > 0 && course.percentPassed < 1 {
                            CourseProgressView(value: 0.5) //course.percentPassed)
                                .frame(width: 50, height: 50)
                                .padding(16)
                        }
                        if course.percentPassed == 1 {
                            MyImageView(name: "cup")
                                .frame(width: 50, height: 50)
                                .padding(16)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .aspectRatio(1, contentMode: .fit)
                    .allowsHitTesting(false)
                }
                Text(course.name)
                    .frame(maxHeight: 50)
                    .font(.custom("LucidaGrande", size: 50))
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .foregroundColor(Color(hex: "303b96ff"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct CourseListItemView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListItemView(course: lines)
            .previewLayout(.fixed(width: 290, height: 300))
    }
}
