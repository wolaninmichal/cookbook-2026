//
//  AppRootView.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 13/01/2026.
//

import SwiftUI

struct AppRootView: View {
    /// Holds the router instance for the lifetime of this view.
    /// Router is the single source of truth for navigation state (`path`).
    @State private var router: AppRouter = .init()

    var body: some View {
        /// `@Bindable` creates bindings to properties of an `@Observable` object,
        /// enabling `$bindableRouter.path`.
        @Bindable var bindableRouter = router

        NavigationStack(path: $bindableRouter.path) {
            BlisterScreen()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case let .squareDetail(pageID, index):
                        SquareDetailView(pageID: pageID, index: index)
                    }
                }
        }
        /// Inject router into the environment.
        .environment(router)
    }
}
