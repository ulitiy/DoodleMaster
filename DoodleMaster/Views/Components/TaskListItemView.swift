//
//  TaskListItemView.swift
//  ArtWorkout
//
//  Created by Aleksandr Ulitin on 10.02.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskListItemView: View {
    @ObservedObject var task: Task
    
    var body: some View {
        NavigationLink(destination: LazyView(TaskView(task: task))) {
            Image("thumbnails/\(task.path)").resizable().aspectRatio(1,contentMode: .fit)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(task.result == 0 ? Color(hex: "303b96ff")! : Color(hex: "00aa66ff")!, lineWidth: 4)
                )
                .overlay(
                    Text(task.name)
                        .font(.custom("LucidaGrande", size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "303b96ff"))
                        .shadow(color: .white, radius: 2)
                        .shadow(color: .white, radius: 2)
                        .shadow(color: .white, radius: 2)
                        .padding(10)
                    , alignment: .bottom)
                .overlay(
                    Group {
                        if task.result > 0 {
                            Text("\(task.result.formatPercent()) %")
                                .font(.custom("LucidaGrande", size: 16))
                                .foregroundColor(task.result == 0 ? Color(hex: "303b96ff")! : Color(hex: "00aa66ff")!)
                                .shadow(color: .white, radius: 2)
                                .shadow(color: .white, radius: 2)
                                .shadow(color: .white, radius: 2)
                                .padding(20)
                        }
                    }
                    , alignment: .topTrailing)
        }.buttonStyle(PlainButtonStyle())
    }
}

struct TaskListItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListItemView(task: courses[0].tasks[0])
    }
}
