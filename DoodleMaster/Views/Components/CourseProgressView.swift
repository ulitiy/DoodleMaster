//
//  CourseProgressView.swift
//  ArtWorkout
//
//  Created by Aleksandr Ulitin on 03.03.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseProgressView: View {
    @ObservedObject var course: Course

    var body: some View {
        ZStack {
            if course.percentPassed > 0 && course.percentPassed < 1 {
                RingProgressView(value: course.percentPassed)
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
}

struct CourseProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CourseProgressView(course: courses[0])
            .frame(width: 200, height: 200)
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
