//
//  CourseListState.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 14.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import Combine

class CourseListState: ObservableObject {
    var cancellables = [AnyCancellable]()
    var courses: [Course]
    
    init(courses: [Course]) {
        self.courses = courses
        courses.forEach { val in
            cancellables.append(val.objectWillChange.sink(receiveValue: { self.objectWillChange.send() }))
        }
    }
}
