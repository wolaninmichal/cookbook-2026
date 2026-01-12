//
//  BlisterCoordinator.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

final class BlisterCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
        
    weak var parent: AppCoordinator?
    private let root: UINavigationController
    
    init(root: UINavigationController) {
        self.root = root
    }
    
    func start() {
        let vm = BlisterTableVM()
        let vc = BlisterTableVC(vm: vm)
        root.setViewControllers([vc], animated: false)
    }
}
