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
    "multistep-first-brush": TaskStep(showResult: false),
    "multistep-result": TaskStep(clearBefore: false, showResult: false, scoringSystem: ScoringSystem(
        oneMinusAlpha: neutral,
        minRed: 0.03,
        weight: 0.0
    )),
    "checkbox": TaskStep(showResult: false, scoringSystem: ScoringSystem(
        oneMinusAlpha: [0.0, 0.0, 0.005, -1], // remove?
        minRed: 0.03,
        weight: 0.0
    )),
    "cursive": TaskStep(brushName: "pen", brushSize: 3.0, brushOpacity: 0.9, shadowSize: 7, scoringSystem: ScoringSystem( // 4-5 + 20%
        roughness: [0.0, 0.0, 1.0, 0],
        oneMinusAlpha: neutral
    )),
]

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
    ]
)

let shapes = Course(
    name: "Shapes",
    path: "shapes",
    description: "--------------",
    tasks: [
        Task(name: "Shapes", path: "shapes/shape"),
        Task(name: "Lollipop", path: "shapes/candy"),
        Task(name: "Town", path: "shapes/town"),
        Task(name: "Balloon dog", path: "shapes/balloon"),
        Task(name: "Shape pattern", path: "shapes/pattern"),
        Task(name: "Penguin", path: "shapes/penguin"),
        Task(name: "3D shapes", path: "shapes/3d-shapes"),
    ]
)

let perspective = Course(
    name: "Perspective",
    path: "perspective",
    description: "--------------",
    tasks: [
        Task(name: "1-point perspective", path: "perspective/1-point-perspective"),
        Task(name: "Rails", path: "perspective/rails"),
        Task(name: "2-point perspective", path: "perspective/2-point-perspective"),
    ]
)

let coursesBase = [lines, shapes, perspective]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG")])]
#else
let courses = coursesBase
#endif
