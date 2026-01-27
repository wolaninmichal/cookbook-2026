//
//  TodoCoordinator.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import UIKit

final class TodoCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let root: UINavigationController
    private let service: TodoServiceProtocol

    var onFinish: (() -> Void)?

    private var listVM: TodoVM?

    init(root: UINavigationController, service: TodoServiceProtocol) {
        self.root = root
        self.service = service
    }

    func start() {
        showList()
    }

    private func showList() {
        let vm = TodoVM(service: service)
        let vc = TodoVC(vm: vm)

        vm.onAddRequested = { [weak self] in
            self?.showCreate()
        }

        vm.onEditRequested = { [weak self] todo in
            self?.showEdit(todo)
        }

        listVM = vm
        root.setViewControllers([vc], animated: false)
    }

    private func showCreate() {
        let vm = TodoEditVM(mode: .create, service: service)
        let vc = TodoEditVC(vm: vm)

        vm.onDismissRequested = { [weak self] in
            self?.root.popViewController(animated: true)
            self?.listVM?.reload()
        }

        vm.onError = { [weak vc] message in
            vc?.presentError(message)
        }

        root.pushViewController(vc, animated: true)
    }

    private func showEdit(_ todo: Todo) {
        let vm = TodoEditVM(mode: .edit(todo), service: service)
        let vc = TodoEditVC(vm: vm)

        vm.onDismissRequested = { [weak self] in
            self?.root.popViewController(animated: true)
            self?.listVM?.reload()
        }

        vm.onError = { [weak vc] message in
            vc?.presentError(message)
        }

        root.pushViewController(vc, animated: true)
    }
}
