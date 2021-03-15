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
                .background(Color.white)
                .cornerRadius(30-1)
                .padding(3)
                .overlay(
                    RoundedRectangle(cornerRadius: 30+3)
                        .stroke(task.result == 0 ? Color(hex: "537fc9ff")! : Color(hex: "3eb93cff")!, lineWidth: 6)
                )
                .overlay(
                    Text(task.name)
                        .frame(maxHeight: 25, alignment: .center)
                        .font(.custom("Helvetica", size: 20))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "537fc9ff"))
                        .shadow(color: .white, radius: 2)
                        .shadow(color: .white, radius: 2)
                        .shadow(color: .white, radius: 2)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                    , alignment: .bottom)
                .overlay(
                    Group {
                        if task.result > 0 {
                            Text("\(task.result.formatScore())")
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(task.result == 0 ? Color(hex: "303b96ff")! : Color(hex: "3eb93cff")!)
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
        TaskListItemView(task: handwriting.tasks[0]).previewLayout(.fixed(width: 250, height: 250))
    }
}
