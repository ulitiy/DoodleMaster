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
    "multistep-brush": TaskStep(clearBefore: false, showResult: false),
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
    path: "lines",
    description: "Line work is one of the basic skills for an artist. It's a common mistake to draw many hairy, chicken scratchy lines. It results in jagged look and lack of flow. In this course you can learn how to draw steady lines confidently. Try to use your whole arm and draw with your elbow and shoulder, not just your wrist.",
    tasks: [
        Task(name: "Straight lines", path: "lines/line"),
        Task(name: "Star", path: "lines/star"),
        Task(name: "Crane", path: "lines/crane"),
        Task(name: "House", path: "lines/house"),
        Task(name: "Curved lines", path: "lines/wave"),
        Task(name: "Fish", path: "lines/fish"),
        Task(name: "Butterfly", path: "lines/butterfly"),
        Task(name: "Shapes", path: "lines/shape"),
        Task(name: "Lollipop", path: "lines/candy"),
        Task(name: "Town", path: "lines/town"),
        Task(name: "Balloon dog", path: "lines/balloon"),
        Task(name: "Shape pattern", path: "lines/pattern"),
        Task(name: "Penguin", path: "lines/penguin"),
    ]
)

let coursesBase = [lines]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG")])]
#else
let courses = coursesBase
#endif
