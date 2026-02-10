//
//  AppCoordinator.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var root: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    var root: UINavigationController = .init()
    let window: UIWindow
    
    private let realmManager: RealmManaging
    
    //MARK: - init
    init(window: UIWindow){
        self.window = window
        self.realmManager = RealmManager()
    }
    
    func start() {
        let repository = RealmTodoRepository(realmManager: realmManager)
        let vm = TodoListVM(repository: repository)
        let vc = TodoListVC(vm: vm)
        
        root.viewControllers = [vc]
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
}
