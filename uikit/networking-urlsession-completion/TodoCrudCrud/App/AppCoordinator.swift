//
//  AppCoordinator.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 20/12/2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var root: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    var root: UINavigationController = .init()
    var window: UIWindow
    
    private let client: HTTPClient
    private let todoService: TodoServiceProtocol
    
    init(window: UIWindow) {
        self.window = window
        
        self.client = URLSessionHTTPClient()
        self.todoService = TodoService(client: client)
    }
    
    func start() {
        let vm = TodoVM(service: todoService)
        let vc = TodoVC(vm: vm)
        
        vm.onAddRequested = { [weak self, weak vm] in
            self?.showCreate(vmToRefresh: vm)
        }
        
        vm.onEditRequested = { [weak self, weak vm] todo in
            guard let vm else { return }
            self?.showEdit(item: todo, vmToRefresh: vm)
        }
        
        root.viewControllers = [vc]
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
    
    private func showCreate(vmToRefresh: TodoVM?) {
        let vm = TodoEditVM(mode: .create, service: todoService)
        let vc = TodoEditVC(vm: vm)
        
        vm.onDismissRequested = { [weak self] in
            self?.root.popViewController(animated: true)
            vmToRefresh?.reload()
        }
        
        root.pushViewController(vc, animated: true)
    }
    
    private func showEdit(item: Todo, vmToRefresh: TodoVM) {
        let vm = TodoEditVM(mode: .edit(item), service: todoService)
        let vc = TodoEditVC(vm: vm)
        
        vm.onDismissRequested = { [weak self, weak vmToRefresh] in
            self?.root.popViewController(animated: true)
            vmToRefresh?.reload()
        }
        
        root.pushViewController(vc, animated: true)
    }
}
