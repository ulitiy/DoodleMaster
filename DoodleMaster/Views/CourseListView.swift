//
//  CourseListView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct CourseListView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 80)],
                      alignment: .center, spacing: 80) {
                ForEach(0...20, id: \.self) { i in
                    NavigationLink(destination: LazyView(TaskView(task: courses[0].tasks[0]))) {
                        VStack {
                            CarouselView {
                                Image("1-1").resizable().aspectRatio(contentMode: .fill)
                                Image("1-2").resizable().aspectRatio(contentMode: .fill)
                                Image("1-3").resizable().aspectRatio(contentMode: .fill)
                                Image("1-4").resizable().aspectRatio(contentMode: .fill)
                            }.aspectRatio(1,contentMode: .fit)
                            Text("Basic human body proportions")
                                .font(.custom("LucidaGrande", size: 25))
                                .foregroundColor(Color(hex: "303b96ff"))
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.padding(50)
        }
        .navigationBarTitle("")
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
