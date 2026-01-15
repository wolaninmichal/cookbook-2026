//
//  AppCoordinator.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    private let window: UIWindow
    private(set) var root: UINavigationController = .init()
    
    init(window: UIWindow){
        self.window = window
    }
    
    func start() {
        let blisterCoord: BlisterCoordinator = .init(root: root)
        blisterCoord.parent = self
        store(child: blisterCoord)
        blisterCoord.start()
        
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
}
