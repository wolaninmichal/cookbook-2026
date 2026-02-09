//
//  AppCoordinator.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import UIKit

protocol Coordinator {
    var root: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    // MARK: - Public
    var root: UINavigationController = .init()
    
    // MARK: - Private
    private var window: UIWindow
    private let di: AppDIContainer
    
    // MARK: - Init
    init(
        window: UIWindow,
        di: AppDIContainer = AppDIContainer()
    ) {
        self.window = window
        self.di = di
    }
    
    // MARK: - Coordinator
    func start() {
        let vc: UIViewController = di.setupHome()
        
        root.viewControllers = [vc]
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
}
