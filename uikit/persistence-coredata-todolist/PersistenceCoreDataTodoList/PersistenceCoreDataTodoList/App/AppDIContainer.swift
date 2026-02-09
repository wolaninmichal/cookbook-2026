//
//  AppDIContainer.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 08/02/2026.
//

import UIKit

final class AppDIContainer {
    private let coreDataStack: CoreDataStackProtocol
    
    init(
        coreDataStack: CoreDataStackProtocol = CoreDataStack()
    ) {
        self.coreDataStack = coreDataStack
    }
    
    func setupHome() -> UIViewController {
        let repository: TodoCDRepository = .init(stack: coreDataStack)
        let vm: HomeVM = .init(repository: repository)
        let vc: HomeVC = .init(vm: vm)
        return vc
    }
}
