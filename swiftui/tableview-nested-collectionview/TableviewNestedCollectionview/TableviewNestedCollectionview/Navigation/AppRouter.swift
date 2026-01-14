//
//  AppRouter.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import Observation

@MainActor
@Observable
final class AppRouter {
    /// navigation status
    var path: [AppRoute] = []

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
