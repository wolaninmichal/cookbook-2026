//
//  AppRouter.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppRouter {
    var path = NavigationPath()

    enum Route: Hashable {
        case addTask

    }

    func push(_ route: Route) { path.append(route) }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
