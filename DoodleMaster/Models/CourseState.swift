//
//  LessonState.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 29.11.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import Combine

class CourseState: ObservableObject {
    @Published var tasks: [Task]
    var cancellables = [AnyCancellable]()
    
    init(tasks: [Task]) {
        self.tasks = tasks
        tasks.forEach { val in
            cancellables.append(val.objectWillChange.sink(receiveValue: { self.objectWillChange.send() }))
        }
    }
}
