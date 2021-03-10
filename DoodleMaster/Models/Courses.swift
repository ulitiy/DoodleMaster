//
//  Courses.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 13.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

let stepTemplates = [
    "default": TaskStep(),
    "multistep": TaskStep(brushName: "pencil", clearBefore: false, showResult: false),
    "multistep-brush": TaskStep(clearBefore: false, showResult: false),
    "multistep-first": TaskStep(brushName: "pencil", showResult: false),
    "multistep-first-brush": TaskStep(showResult: false),
    "multistep-brush-first": TaskStep(showResult: false),
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
    "handwriting": TaskStep(brushName: "pen", brushSize: 3.0, shadowSize: 11.1, scoringSystem: ScoringSystem( // 11.1 - perfect
        roughness: [0.0, 0.0, 1.0, 0],
        oneMinusAlpha: [0.0, 0.0, 0.002, -1]
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
    description: "In this course you will learn how to draw with 1, 2 and 3 vanishing points.",
    tasks: [
        Task(name: "1-point perspective", path: "perspective/1-point"),
        Task(name: "Rails", path: "perspective/rails"),
        Task(name: "Room", path: "perspective/room"),
        Task(name: "2-point perspective", path: "perspective/2-point"),
        Task(name: "City", path: "perspective/city"),
        Task(name: "3-point perspective", path: "perspective/3-point"),
    ]
)

let flowers = Course(
    name: "Flowers",
    path: "flowers",
    description: "In this course you will learn how to draw flowers, leaves and cactuses.",
    tasks: [
        Task(name: "Flower 1", path: "flowers/flower1"),
        Task(name: "Flower 2", path: "flowers/flower2"),
        Task(name: "Flower 3", path: "flowers/flower3"),
        Task(name: "Leaves", path: "flowers/leaves"),
        Task(name: "Vase", path: "flowers/vase"),
        Task(name: "Branch", path: "flowers/branch"),
        Task(name: "Texture", path: "flowers/texture"),
        Task(name: "Cactus", path: "flowers/cactus"),
    ]
)

let letters = Course(
    name: "Letters",
    path: "letters",
    description: "In this course you will learn how to write A-Z cursive letters step by step",
    tasks: [
        Task(name: "Letters Aa-Hh", path: "letters/a-h"),
    ])

let handwriting = Course(
    name: "Handwriting practice",
    path: "handwriting",
    description: "This course contains handwriting practice from popular children's poems.",
    tasks: [
        Task(name: "From a Railway Carriage pt.1", path: "handwriting/from-a-railway-carriage-1", text: [
            "Faster than fairies, faster than witches,",
            "Bridges and houses, hedges and ditches;",
            "And charging along like troops in a battle,",
            "All through the meadows the horses and cattle:",
            "All of the sights of the hill and the plain",
            "Fly as thick as driving rain;",
            "And ever again, in the wink of an eye,",
            "Painted stations whistle by.",
        ]),
        Task(name: "From a Railway Carriage pt.2", path: "handwriting/from-a-railway-carriage-2", text: [
            "Here is a child who clambers and scrambles,",
            "All by himself and gathering brambles;",
            "Here is a tramp who stands and gazes;",
            "And there is the green for stringing the daisies!",
            "Here is a cart run away in the road",
            "Lumping along with man and load;",
            "And here is a mill and there is a river:",
            "Each a glimpse and gone for ever!",
        ]),
    ]
)

let coursesBase = [lines, shapes, perspective, flowers, handwriting]

#if DEBUG
let courses = coursesBase + [Course(name: "Test", path: "DEBUG", description: "", tasks: [Task(name: "Test", path: "DEBUG")])]
#else
let courses = coursesBase
#endif
