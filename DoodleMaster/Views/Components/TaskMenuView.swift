//
//  TaskMenuView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 04.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI
import Amplitude_iOS

struct TaskMenuView: View {
    @ObservedObject var taskState: TaskState
    @State private var showRestartAlert = false
    @State private var showBackToMenuAlert = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        HStack {
            Menu {
                Button("Restart step", action: { taskState.failStep() })
                Button("Restart task", action: { showRestartAlert.toggle() })
                Toggle("Skip animations", isOn: $taskState.skipAnimation)
                Button("Exit to menu", action: { showBackToMenuAlert.toggle() })
            } label: {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                    .font(.system(size: 50, weight: .heavy))
            }
            
            #if DEBUG
            Button(action: {
                taskState.passStep()
                if taskState.currentStep.showResult {
                    taskState.switchNextStep()
                }
            }) {
                Image(systemName: "chevron.right.2")
                    .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                    .font(.system(size: 50))
            }
            Button(action: {
                taskState.debugTemplate.toggle()
            }) {
                Image(systemName: "pencil.tip.crop.circle")
                    .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                    .font(.system(size: 50))
            }
            #endif
            
            ZStack {
            }
            .alert(isPresented: $showRestartAlert) {
                Alert(title: Text("Are you sure want to restart the task?"), primaryButton: .default(Text("Yes"), action: { taskState.restartTask() }), secondaryButton: .default(Text("Cancel")))
            }
            ZStack {
            }
            .alert(isPresented: $showBackToMenuAlert) {
                Alert(title: Text("Are you sure want to return to menu?"), primaryButton: .default(Text("Yes"), action: {
                    self.presentationMode.wrappedValue.dismiss()
                    Amplitude.instance().logEvent("task_exit", withEventProperties: [
                        "task_path": taskState.task.path,
                        "step_number": taskState.stepNumber,
                        "name": taskState.task.name,
                        "times_failed": taskState.timesFailed,
                    ])
                }), secondaryButton: .default(Text("Cancel")))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}

struct TaskMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TaskMenuView(taskState: TaskState(task: Task(name: "Line", path: "Basics/1/1")))
    }
}
