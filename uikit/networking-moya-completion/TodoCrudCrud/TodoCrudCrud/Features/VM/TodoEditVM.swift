//
//  TodoEditVM.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation

final class TodoEditVM {
    enum Mode {
        case create
        case edit(Todo)
    }

    private(set) var mode: Mode
    private let service: TodoServiceProtocol

    var onDismissRequested: (() -> Void)?
    var onError: ((String) -> Void)?

    init(mode: Mode, service: TodoServiceProtocol) {
        self.mode = mode
        self.service = service
    }

    var initialTitle: String {
        switch mode {
        case .create:
            return ""
        case .edit(let todo):
            return todo.title
        }
    }

    var initialIsDone: Bool {
        switch mode {
        case .create:
            return false
        case .edit(let todo):
            return todo.isDone
        }
    }

    func save(title: String, isDone: Bool) {
        switch mode {

        case .create:
            service.create(title: title, isDone: isDone) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.onDismissRequested?()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }

        case .edit(var todo):
            todo.title = title
            todo.isDone = isDone

            service.update(todo: todo) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.onDismissRequested?()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
