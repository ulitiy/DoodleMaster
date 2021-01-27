//
//  CourseDescriptionView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 23.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseDescriptionView: View {
    @ObservedObject var course: Course

    var body: some View {
        HStack {
            Image("thumbnails/\(course.path)/index")
                .resizable()
                .frame(width: 300, height: 300)
                .aspectRatio(1,contentMode: .fit)
                .cornerRadius(40)
                .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color(hex: "303b96ff")!, lineWidth: 4))
                .padding(.trailing, 50)
            VStack(alignment: .leading, spacing: 20) {
                Text(course.name)
                    .font(.custom("LithosPro-Regular", size: 50.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .padding(.top, 10)
                Text(course.description)
                    .font(.custom("LucidaGrande", size: 30))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .lineSpacing(10)
                    .minimumScaleFactor(0.7)
                    .lineLimit(10)
            }.frame(height: 300, alignment: .topLeading)
        }.padding(40)

    }
}

struct CourseDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDescriptionView(course: courses[0]).previewLayout(.fixed(width: 1366, height: 1024))
        CourseDescriptionView(course: Course(name: "Some long name for a course",path: "", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.", tasks: [])).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
