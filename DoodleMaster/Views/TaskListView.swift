//
//  TaskListView.swift
//  DrawingTutor
//
//  Created by Alexander Ulitin on 25.08.2019.
//  Copyright © 2019 Alexander Ulitin. All rights reserved.
//

import SwiftUI

let multistep = TaskStep(brushName: "pencil", clearBefore: false, showResult: false) // how long show result?
let multistepFirst = TaskStep(brushName: "pencil", showResult: false)
let multistepResult = TaskStep(clearBefore: false, showResult: false, scoringSystem: ScoringSystem(
    blue: any,
    oneMinusAlpha: neutral,
    weight: 0
))
let arrowStep = TaskStep(showResult: false, scoringSystem: ScoringSystem(weight: 0))
let checkBoxStep = TaskStep(showResult: false, scoringSystem: ScoringSystem(
    blue: any,
    oneMinusAlpha: [0.0, 0.0, 0.005, -1], // remove?
    weight: 0
))
let smoothLineStep = TaskStep(shadowSize: 80, scoringSystem: ScoringSystem(
    overlap: [0.07, 0.0, 0.15, -1.0],
    roughness: smooth,
    strokeCount: oneStroke
))
let hatchingStep = TaskStep(brushSize: 15, shadowSize: 80, scoringSystem: ScoringSystem(
    overlap: [0.16, 0.0, 0.2, -1.0], // 0.16-0.2 ok, >0.2 - not ok
    blue: [0.0, 0.0, 1.0, 1.0, 1.0]
))

struct TaskListView: View {
    @StateObject var lessonState = LessonState(tasks: [
        Task(name: "Intro", path: "Basics/1/1", steps: [
            arrowStep,
            arrowStep,
            checkBoxStep,
            checkBoxStep,
            smoothLineStep,
            TaskStep(scoringSystem: ScoringSystem(
                roughness: rough,
                strokeCount: oneStroke
            )),
            TaskStep(brushSize: 7, shadowSize: 20),
            TaskStep(),
            TaskStep(brushSize: 40),
            hatchingStep,
            multistepFirst, // cube
            multistep,
            multistep,
            multistep,
            multistepResult,
            TaskStep(scoringSystem: ScoringSystem(
                blue: any,
                oneMinusAlpha: neutral,
                weight: 0
            )),
        ]),
        Task(name: "Loomis", path: "Basics/1/2", steps: [
            multistep,
            multistep,
            multistep,
            multistep,
            multistep,
            multistep,
            multistep,
            multistep,
            multistepResult,
        ]),
        Task(name: "Интро", path: "Basics/1/3", steps: [
            arrowStep,
            arrowStep,
            checkBoxStep,
            checkBoxStep,
            smoothLineStep,
            TaskStep(scoringSystem: ScoringSystem(
                roughness: rough,
                strokeCount: oneStroke
            )),
            TaskStep(brushSize: 7, shadowSize: 20),
            TaskStep(),
            TaskStep(brushSize: 40),
            hatchingStep,
            multistepFirst, // cube
            multistep,
            multistep,
            multistep,
            multistepResult,
            TaskStep(scoringSystem: ScoringSystem(
                blue: any,
                oneMinusAlpha: neutral,
                weight: 0
            )),
        ]),
    ])
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 65) {
                ForEach(lessonState.tasks, id: \.path) {task in
                    NavigationLink(destination: LazyView(TaskView(task: task))) {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 12)
                                    .foregroundColor(Color(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                                    .frame(width: 236, height: 236)
                                Circle()
                                    .frame(width: 200, height: 200, alignment: .leading)
                                Text(task.name)
                                    .font(.system(size: 50))
                                    .foregroundColor(Color.white)
                            }
                            Text(String(format: "%.2f", task.result * 100))
                                .font(.system(size: 30))
                        }
                    }
                }
            }
            .padding(.leading, 65)
            .frame(minHeight: 0, maxHeight: .infinity)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView().previewLayout(.fixed(width: 1366, height: 1024))
    }
}
#endif
