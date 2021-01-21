//
//  Courses.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

let multistep = TaskStep(brushName: "pencil", brushOpacity: 0.3, clearBefore: false, showResult: false) // how long show result?
let multistepFirst = TaskStep(brushName: "pencil", brushOpacity: 0.3, showResult: false)
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
    roughness: smooth,
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

let coursesBase = [Course(
    name: "Basics",
    path: "Basics",
    description: "Some bacics",
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
])]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG", steps: Array.init(repeating: TaskStep(), count: 30))])]
#else
let courses = coursesBase
#endif

let globalState = CourseListState(courses: courses)
