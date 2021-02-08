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
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 80)],
                      alignment: .center, spacing: 80) {
                ForEach(courseListState.courses, id: \.path) { course in
                    CourseListItemView(course: course)
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
