//
//  AppDIContainer.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftUI
import SwiftData

final class AppDIContainer {
    let stack: SwiftDataStackProtocol

    lazy var homeViewModel: HomeViewModel = {
        let repo = SwiftDataTodoRepository(context: stack.mainContext)
        return HomeViewModel(repository: repo, context: stack.mainContext)
    }()

    init() {
        do {
            self.stack = try SwiftDataStack(inMemory: false)
        } catch {
            fatalError("SwiftDataStack init failed: \(error)")
        }
    }

    func makeHome() -> some View {
        HomeView(vm: homeViewModel)
    }

    func makeAddTask() -> some View {
        AddTaskView(vm: homeViewModel)
    }
}
