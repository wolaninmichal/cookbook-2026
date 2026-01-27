//
//  TodoVM.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation

final class TodoVM {
    enum State {
        case idle
        case loading
        case loaded
        case error(String)
    }

    var onStateChange: ((State) -> Void)?
    var onAddRequested: (() -> Void)?
    var onEditRequested: ((Todo) -> Void)?

    private(set) var todos: [Todo] = []
    private let service: TodoServiceProtocol

    init(service: TodoServiceProtocol) {
        self.service = service
    }

    func viewDidLoad() {
        reload()
    }

    func reload() {
        onStateChange?(.loading)

        service.fetchAll { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.todos = items.sorted(by: { $0.createdAt > $1.createdAt })
                self.onStateChange?(.loaded)
            case .failure(let error):
                self.onStateChange?(.error(error.localizedDescription))
            }
        }
    }

    func addTapped() {
        onAddRequested?()
    }

    func didSelect(at index: Int) {
        guard todos.indices.contains(index) else { return }
        onEditRequested?(todos[index])
    }
}
