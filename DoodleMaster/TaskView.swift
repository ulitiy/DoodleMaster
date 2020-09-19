//
//  ContentView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 17.08.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskView: View {
    var body: some View {
        ZStack {
            Image("1-task")
                .resizable()
                .aspectRatio(contentMode: .fit)
            CanvasContainerRepresentation()
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView().previewLayout(.fixed(width: 1366, height: 1024))
    }
}
