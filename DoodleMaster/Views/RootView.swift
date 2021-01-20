//
//  TaskListView.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            CourseListView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .statusBar(hidden: true)
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().previewLayout(.fixed(width: 1366, height: 1024))
    }
}
#endif
