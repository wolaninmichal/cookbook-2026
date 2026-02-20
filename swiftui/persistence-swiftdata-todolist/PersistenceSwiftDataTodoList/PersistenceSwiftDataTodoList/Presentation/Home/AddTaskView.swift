//
//  AddTaskView.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {

    let vm: HomeViewModel
    @Environment(AppRouter.self) private var router
    @State private var title: String = ""

    var body: some View {
        Form {
            TextField("Buy some milk", text: $title)
                .textInputAutocapitalization(.sentences)
        }
        .navigationTitle("New task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { router.pop() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let ok = vm.addTask(title: title)
                    if ok { router.pop() }
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

#Preview("Add Task") {
    let stack = try! SwiftDataStack(inMemory: true)
    let repo = SwiftDataTodoRepository(context: stack.mainContext)
    let vm = HomeViewModel(repository: repo, context: stack.mainContext)
    let router = AppRouter()

    return NavigationStack {
        AddTaskView(vm: vm)
    }
    .environment(router)
}
