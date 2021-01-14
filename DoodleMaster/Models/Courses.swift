//
//  Courses.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

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

let courses = [Course(
    name: "Basics",
    path: "Basics",
    description: "Some bacics",
    tasks: [
        Task(name: "Intro", path: "Basics/1/1", steps: introSteps),
        Task(name: "Интро", path: "Basics/1/3", steps: introSteps),
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
])]
