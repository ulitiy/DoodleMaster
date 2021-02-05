//
//  Courses.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

let smoothStep = TaskStep(scoringSystem: ScoringSystem(roughness: smooth))
let multistep = TaskStep(brushName: "pencil", brushOpacity: 0.8, clearBefore: false, showResult: false, scoringSystem: ScoringSystem(roughness: smooth)) // how long show result?
let multistepFirst = TaskStep(brushName: "pencil", brushOpacity: 0.8, showResult: false, scoringSystem: ScoringSystem(roughness: smooth))
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
    overlap: [0.04, 0.0, 0.06, -1.0],
    roughness: smoothPunish,
    strokeCount: oneStroke
))
let hatchingStep = TaskStep(brushSize: 15, shadowSize: 80, scoringSystem: ScoringSystem(
    overlap: [0.05, 0.0, 0.06, -1.0], // 0.08-0.1
    blue: [0.0, 0.0, 1.0, 1.0, 0.985]
))

let introSteps = [
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
]

let basics = Course(
    name: "Basics",
    path: "Basics",
    description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
    tasks: [
        Task(name: "Intro", path: "Basics/1", steps: introSteps),
        Task(name: "Интро", path: "Basics/3", steps: introSteps),
        Task(name: "Loomis", path: "Basics/2", steps: [
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
])

let lines = Course(
    name: "Lines",
    path: "Lines",
    description: "Line work is one of the basic skills for an artist. It's a common mistake to draw many hairy, chicken scratchy lines. It results in jagged look and lack of flow. In this course you can learn how to draw steady lines confidently. Try to use your whole arm and draw with your elbow and shoulder, not just your wrist.",
    tasks: [
        Task(name: "Straight lines", path: "Lines/1", steps: [TaskStep](repeating: smoothStep, count: 11)),
        Task(name: "Star", path: "Lines/2", steps: [TaskStep](repeating: multistep, count: 5) + [multistepResult]),
        Task(name: "Swan", path: "Lines/3", steps: [TaskStep](repeating: multistep, count: 8) + [multistepResult]),
        Task(name: "House", path: "Lines/4", steps: [TaskStep](repeating: multistep, count: 11) + [multistepResult]),
        Task(name: "Curved lines", path: "Lines/5", steps: [TaskStep](repeating: smoothStep, count: 17)),
        Task(name: "Fish", path: "Lines/6", steps: [TaskStep](repeating: multistep, count: 7) + [multistepResult]),
        Task(name: "Butterfly", path: "Lines/7", steps: [TaskStep](repeating: multistep, count: 9) + [TaskStep(), multistepResult]),
        Task(name: "Shapes", path: "Lines/8", steps:
                [TaskStep](repeating: smoothStep, count: 5) +
                [multistepFirst, multistep, multistep] +
                [TaskStep](repeating: smoothStep, count: 5)
        ),
        Task(name: "Lollipop", path: "Lines/9", steps: [TaskStep](repeating: multistep, count: 3) + [multistepResult]),
        Task(name: "Sky city", path: "Lines/10", steps: [TaskStep](repeating: multistep, count: 17) + [multistepResult]),
        Task(name: "Balloon dog", path: "Lines/11", steps:
                [TaskStep](repeating: smoothStep, count: 3) +
                [multistepFirst] + [TaskStep](repeating: multistep, count: 9) +
                [multistepFirst] + [TaskStep](repeating: multistep, count: 6) + [multistepResult]
        ),
        Task(name: "Shape pattern", path: "Lines/12", steps: [TaskStep](repeating: multistep, count: 12) + [multistepResult]),
        Task(name: "Penguin", path: "Lines/13", steps: [TaskStep](repeating: multistep, count: 14) + [multistepResult]),
        Task(name: "Oblique projection", path: "Lines/14", steps:
                [TaskStep](repeating: multistep, count: 6) +
                [multistepFirst, multistep, multistep] +
                [multistepFirst, multistep] +
                [multistepFirst, multistep, multistep]
        ),
    ]
)

let coursesBase = [basics, lines]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG", steps: [TaskStep](repeating: TaskStep(), count: 30))])]
#else
let courses = coursesBase
#endif

let globalState = CourseListState(courses: courses)
