//
//  CourseListView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseListView: View {
    @StateObject var courseListState = CourseListState(courses: courses)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260, maximum: 300), spacing: 80)],
                      alignment: .center, spacing: 25) {
                ForEach(courseListState.courses, id: \.path) { course in
                    CourseListItemView(course: course).frame(width: 300, height: 420)
                }
            }.padding(60)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(white: 0.25), Color(white:0.05)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .navigationTitle("Courses")
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
            .previewDevice("iPad (8th generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
        CourseListView()
            .previewDevice("iPad (8th generation)")
            .previewLayout(.fixed(width: 1080, height: 810))
    }
}
