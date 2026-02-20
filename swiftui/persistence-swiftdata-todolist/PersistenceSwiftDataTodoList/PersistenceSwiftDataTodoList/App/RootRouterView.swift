//
//  RootRouterView.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftUI
import Observation

struct RootRouterView: View {

    @Bindable var router: AppRouter
    let di: AppDIContainer

    var body: some View {
        NavigationStack(path: $router.path) {
            di.makeHome()
                .navigationDestination(for: AppRouter.Route.self) { route in
                    switch route {
                    case .addTask:
                        di.makeAddTask()
                    }
                }
        }
    }
}
