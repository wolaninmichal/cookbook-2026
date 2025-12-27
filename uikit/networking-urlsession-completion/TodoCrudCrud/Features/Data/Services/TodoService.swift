//
//  TodoService.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

protocol TodoServiceProtocol {
    func fetchAll(completion: @escaping (Result<[Todo], Error>) -> Void)
    func create(title: String, isDone: Bool, completion: @escaping (Result<Todo, Error>) -> Void)
    func update(todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class TodoService: TodoServiceProtocol {

    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchAll(completion: @escaping (Result<[Todo], Error>) -> Void) {
        client.send(TodoAPI.list, completion: completion)
    }

    func create(title: String, isDone: Bool, completion: @escaping (Result<Todo, Error>) -> Void) {
        let payload = TodoUpsertPayload(title: title, isDone: isDone, createdAt: Date())
        client.send(TodoAPI.create, body: payload, completion: completion)
    }

    func update(todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        /// CrudCrud: PUT bez `_id` w body
        let payload = TodoUpsertPayload(title: todo.title, isDone: todo.isDone, createdAt: todo.createdAt)
        client.send(TodoAPI.update(id: todo.id), body: payload, completion: completion)
    }

    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        client.send(TodoAPI.delete(id: id), completion: completion)
    }
}
