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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            ZStack {
                Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "537fc9ff"))
                        .font(.system(size: 60, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 30)
            HStack {
                ZStack {
                    Image("thumbnails/\(course.path)/index")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color.white)
                        .cornerRadius(40 - 1)
                        .padding(3.5)
                        .overlay(RoundedRectangle(cornerRadius: 40 + 3.5).stroke(Color(hex: "537fc9ff")!, lineWidth: 7))
                    CourseProgressView(course: course)
                }
                .frame(width: 300, height: 300)
                .padding(.trailing, 50)
                VStack(alignment: .leading, spacing: 20) {
                    Text(course.name.replacingOccurrences(of: "\n", with: " "))
                        .font(.custom("Montserrat-Medium", size: 50.0))
                        .foregroundColor(Color.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .padding(.top, 10)
                    Text(course.description)
                        .font(.custom("Helvetica", size: 30))
                        .foregroundColor(Color.white)
                        .lineSpacing(10)
                        .minimumScaleFactor(0.7)
                        .lineLimit(10)
                }
                .frame(minWidth: 500, minHeight: 300, maxHeight: 300, alignment: .topLeading)
            }.padding(.vertical, 40).padding(.horizontal, 100)
        }
    }
}

struct CourseDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        CourseDescriptionView(course: courses[0]).previewLayout(.fixed(width: 1366, height: 1024))
        CourseDescriptionView(course: Course(name: "Some\n long name for a course!",path: "", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.", tasks: [])).previewLayout(.fixed(width: 1200, height: 900))
        CourseDescriptionView(course: Course(name: "Name",path: "", description: "Lorem Ipsum", tasks: [])).previewLayout(.fixed(width: 1366, height: 1024))
    }
}
