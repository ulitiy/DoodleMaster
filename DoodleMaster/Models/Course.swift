//
//  Course.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 29.11.2020.
//  Copyright © 2020 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Combine

class Course: ObservableObject {
    var name: String
    var path: String
    var description: String
    var tasks: [Task]
    var cancellables = [AnyCancellable]()
    var passed: Bool {
        get {
            UserDefaults.standard.bool(forKey: path + ".coursePassed")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: path + ".coursePassed")
            objectWillChange.send()
        }
    }
    
    init(name: String, path: String, description: String, tasks: [Task]) {
        self.name = name
        self.path = path
        self.description = description
        self.tasks = tasks
        tasks.forEach { val in
            cancellables.append(val.objectWillChange.sink(receiveValue: { self.objectWillChange.send() }))
        }
        cancellables.append(objectWillChange.sink {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let p = tasks.first(where: {
                    $0.result == 0
                }) == nil
                if self.passed != p {
                    self.passed = p // true
                }
            }
        })
    }
}
