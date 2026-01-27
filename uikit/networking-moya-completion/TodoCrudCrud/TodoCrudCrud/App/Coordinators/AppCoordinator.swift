//
//  AppCoordinator.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func store(child childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }

    func restore(child childCoordinator: Coordinator) {
        childCoordinators.removeAll { $0 === childCoordinator }
    }
}

import UIKit
import Moya

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let root: UINavigationController = .init()
    private let window: UIWindow

    private let todoService: TodoServiceProtocol

    init(window: UIWindow) {
        self.window = window

        let logger = NetworkLoggerPlugin(configuration: .init(
            logOptions: [
                .requestMethod,
                .requestHeaders,
                .requestBody,
                .successResponseBody,
                .errorResponseBody
            ]
        ))

        let provider = MoyaProvider<TodoAPI>(plugins: [logger])
        self.todoService = TodoService(provider: provider, callbackQueue: .main)
    }

    func start() {
        window.rootViewController = root
        window.makeKeyAndVisible()

        let todoCoordinator = TodoCoordinator(
            root: root,
            service: todoService
        )

        store(child: todoCoordinator)
        todoCoordinator.onFinish = { [weak self, weak todoCoordinator] in
            guard let self, let todoCoordinator else { return }
            self.restore(child: todoCoordinator)
        }

        todoCoordinator.start()
    }
}
