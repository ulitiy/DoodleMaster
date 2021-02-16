//
//  CoursePassedView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 01.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CoursePassedView: View {
    @ObservedObject var course: Course

    var body: some View {
        ZStack {
            Rectangle().fill(Color.white)
            VStack(spacing: 60) {
                Text("Congratulations!!!")
                    .font(.custom("LithosPro-Regular", size: 50.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .padding(.top, 100)
                MyImageView(name: "cup")
                    .frame(width: 300, height: 300)
                Text("Course passed")
                    .font(.custom("LithosPro-Regular", size: 70.0))
                    .foregroundColor(Color(hex: "303b96ff"))
                    .padding(.bottom, 30)
                Button(action: { course.firstTimePassed = false }) {
                    Text("OK")
                        .font(.custom("LucidaGrande", size: 50))
                        .padding(.horizontal, 80)
                        .padding(.vertical, 30)
                        .overlay(RoundedRectangle(cornerRadius: 500).stroke(lineWidth: 4))
                    .foregroundColor(Color(hex: "303b96ff"))
                }
            }.padding(.bottom, 50)
        }
        .zIndex(2)
        .transition(AnyTransition.opacity.combined(with: .scale).animation(.easeInOut(duration: 0.2)))
    }
}

struct CoursePassedView_Previews: PreviewProvider {
    static var previews: some View {
        CoursePassedView(course: lines)
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
