//
//  Course.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 29.11.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Combine
import Amplitude_iOS

class Course: ObservableObject {
    var name: String
    var path: String
    var description: String
    var tasks: [Task]
    var cancellables = [AnyCancellable]()
    var tasksPassed: Int {
        get {
            UserDefaults.standard.integer(forKey: path + ".tasksPassed")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: path + ".tasksPassed")
            print("Setting \(newValue) for \(path + ".tasksPassed")")
            percentPassed = Double(tasksPassed) / Double(tasks.count)
            objectWillChange.send()
        }
    }
    @Published var percentPassed = 0.0 {
        willSet(val) {
            if percentPassed > 0 && percentPassed < 1 && val == 1 { // 0->1 means startup or 1-task course, no need for congrats
                firstTimePassed = true
                Amplitude.instance().logEvent("course_pass", withEventProperties: [
                    "path": path,
                    "name": name,
                    "tasks_count": tasks.count,
                ])
            }
        }
    }
    @Published var firstTimePassed = false
    
    init(name: String, path: String, description: String, tasks: [Task]) {
        self.name = name
        self.path = path
        self.description = description
        self.tasks = tasks
        percentPassed = Double(tasksPassed) / Double(tasks.count)
        tasks.forEach { val in
            cancellables.append(val.objectWillChange.sink(receiveValue: { self.objectWillChange.send() }))
        }
        cancellables.append(objectWillChange.sink {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let p = tasks.filter {
                    $0.result > 0
                }.count
                if self.tasksPassed != p {
                    self.tasksPassed = p
                }
            }
        })
    }
}
