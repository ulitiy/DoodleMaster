//
//  TaskOverlayView.swift
//  DoodleMaster
//
//  Created by Aleksandr Ulitin on 03.01.2021.
//  Copyright © 2021 Aleksandr Ulitin. All rights reserved.
//

import SwiftUI

struct TaskOverlayView: View {
    @ObservedObject var taskState: TaskState
    @State private var showRestartAlert = false
    @State private var showBackToMenuAlert = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            // top
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
                Button(action: { taskState.passStep() }) {
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)))
                        .font(.system(size: 50))
                }
                #endif
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .alert(isPresented: $showRestartAlert) {
                Alert(title: Text("Are you sure want to restart the task?"), primaryButton: .default(Text("Yes"), action: { taskState.restartTask() }), secondaryButton: .default(Text("Cancel")))
            }
            
            #if DEBUG
            Text(taskState.currentResult.positive.formatPercent())
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            #endif
            
            Text("\(taskState.stepNumber) / \(taskState.task.steps.count)")
                .font(.custom("LucidaGrande", size: 30))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))//
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding()
            .alert(isPresented: $showBackToMenuAlert) {
                Alert(title: Text("Are you sure want to return to menu?"), primaryButton: .default(Text("Yes"), action: { self.presentationMode.wrappedValue.dismiss() }), secondaryButton: .default(Text("Cancel")))
            }

            // bottom
            
            if taskState.whyFailed != nil {
                WhyFailedView(whyFailed: taskState.whyFailed!)
            }
        }
    }
}

struct TaskOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TaskOverlayView(taskState: TaskState(task: Task(name: "Line", path: "Basics/1/1", steps: [TaskStep()])))
            .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
