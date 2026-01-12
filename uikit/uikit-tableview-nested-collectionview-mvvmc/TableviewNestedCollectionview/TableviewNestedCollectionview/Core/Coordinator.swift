//
//  Coordinator.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func store(child coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func free(child coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
