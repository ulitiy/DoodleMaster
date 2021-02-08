//
//  Courses.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

let stepTemplates = [
    "default": TaskStep(),
    "multistep": TaskStep(brushName: "pencil", brushOpacity: 0.8, clearBefore: false, showResult: false),
    "multistep-first": TaskStep(brushName: "pencil", brushOpacity: 0.8, showResult: false),
    "multistep-result": TaskStep(clearBefore: false, showResult: false, scoringSystem: ScoringSystem(
        oneMinusAlpha: neutral,
        minRed: any,
        weight: 0.0
    )),
    "checkbox": TaskStep(showResult: false, scoringSystem: ScoringSystem(
        oneMinusAlpha: [0.0, 0.0, 0.005, -1], // remove?
        minRed: any,
        weight: 0.0
    )),
]

//let basics = Course(
//    name: "Draw heads",
//    path: "Heads",
//    description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
//    tasks: [
//        Task(name: "Loomis", path: "Basics/2", steps: [
//            multistep,
//            multistep,
//            multistep,
//            multistep,
//            multistep,
//            multistep,
//            multistep,
//            multistep,
//            multistepResult,
//        ]),
//])

let lines = Course(
    name: "Lines",
    path: "Lines",
    description: "Line work is one of the basic skills for an artist. It's a common mistake to draw many hairy, chicken scratchy lines. It results in jagged look and lack of flow. In this course you can learn how to draw steady lines confidently. Try to use your whole arm and draw with your elbow and shoulder, not just your wrist.",
    tasks: [
        Task(name: "Straight lines", path: "Lines/1"),
        Task(name: "Star", path: "Lines/2"),
        Task(name: "Swan", path: "Lines/3"),
//        Task(name: "House", path: "Lines/4", steps: [TaskStep](repeating: multistep, count: 11) + [multistepResult]),
//        Task(name: "Curved lines", path: "Lines/5", steps: [TaskStep](repeating:  TaskStep(), count: 17)),
//        Task(name: "Fish", path: "Lines/6", steps: [TaskStep](repeating: multistep, count: 7) + [multistepResult]),
//        Task(name: "Butterfly", path: "Lines/7", steps: [TaskStep](repeating: multistep, count: 9) + [TaskStep(), multistepResult]),
        Task(name: "Shapes", path: "Lines/8")
//        Task(name: "Lollipop", path: "Lines/9", steps: [TaskStep](repeating: multistep, count: 3) + [multistepResult]),
//        Task(name: "Sky city", path: "Lines/10", steps: [TaskStep](repeating: multistep, count: 17) + [multistepResult]),
//        Task(name: "Balloon dog", path: "Lines/11", steps:
//                [TaskStep](repeating:  TaskStep(), count: 3) +
//                [multistepFirst] + [TaskStep](repeating: multistep, count: 9) +
//                [multistepFirst] + [TaskStep](repeating: multistep, count: 6) + [multistepResult]
//        ),
//        Task(name: "Shape pattern", path: "Lines/12", steps: [TaskStep](repeating: multistep, count: 12) + [multistepResult]),
//        Task(name: "Penguin", path: "Lines/13", steps: [TaskStep](repeating: multistep, count: 14) + [multistepResult]),
//        Task(name: "Oblique projection", path: "Lines/14", steps:
//                [TaskStep](repeating: multistep, count: 6) +
//                [multistepFirst, multistep, multistep] +
//                [multistepFirst, multistep] +
//                [multistepFirst, multistep, multistep]
//        ),
    ]
)

let coursesBase = [lines]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG")])]
#else
let courses = coursesBase
#endif
