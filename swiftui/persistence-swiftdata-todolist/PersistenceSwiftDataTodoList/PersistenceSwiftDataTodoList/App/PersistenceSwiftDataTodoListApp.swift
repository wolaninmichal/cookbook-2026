//
//  PersistenceSwiftDataTodoListApp.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 19/02/2026.
//

import SwiftUI
import SwiftData

@main
struct PersistenceSwiftDataTodoListApp: App {

    @State private var router = AppRouter()
    private let di = AppDIContainer()

    var body: some Scene {
        WindowGroup {
            RootRouterView(router: router, di: di)
                .environment(router)
        }
        .modelContainer(di.stack.container)
    }
}
