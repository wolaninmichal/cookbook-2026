//
//  TodoVM.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 20/12/2025.
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
        service.fetchAll(delegate: self)
    }

    func addTapped() {
        onAddRequested?()
    }

    func didSelect(at index: Int) {
        guard todos.indices.contains(index) else { return }
        onEditRequested?(todos[index])
    }
}

extension TodoVM: TodoServiceDelegate {
    func todoService(_ service: TodoServiceProtocol, didFetchAll result: Result<[Todo], Error>) {
        switch result {
        case .success(let items):
            todos = items.sorted(by: { $0.createdAt > $1.createdAt })
            onStateChange?(.loaded)
        case .failure(let error):
            onStateChange?(.error(error.localizedDescription))
        }
    }
}
