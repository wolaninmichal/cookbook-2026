//
//  TodoService.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation
import Moya

protocol TodoServiceProtocol {
    func fetchAll(completion: @escaping (Result<[Todo], Error>) -> Void)
    func create(title: String, isDone: Bool, completion: @escaping (Result<Todo, Error>) -> Void)
    func update(todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class TodoService: TodoServiceProtocol {
    private let provider: MoyaProvider<TodoAPI>
    private let callbackQueue: DispatchQueue
    
    init(
        provider: MoyaProvider<TodoAPI>,
        callbackQueue: DispatchQueue = .main
    ) {
        self.provider = provider
        self.callbackQueue = callbackQueue
    }
    
    func fetchAll( /// GET
        completion: @escaping (Result<[Todo], any Error>) -> Void
    ) {
        provider.request(.list) { [callbackQueue] result in
            callbackQueue.async {
                switch result {
                case .success(let response):
                    do {
                        let todo = try JSONCoding.decoder.decode([Todo].self, from: response.data)
                        completion(.success(todo))
                    } catch {
                        completion(.failure(NetworkError.decoding(error)))
                    }
                case .failure(let error):
                    completion(.failure(NetworkError.moya(error)))
                }
            }
        }
    }
    
    func create( /// POST
        title: String,
        isDone: Bool,
        completion: @escaping (Result<Todo, Error>) -> Void
    ) {
        let payload = TodoUpsertPayload(title: title, isDone: isDone, createdAt: Date())

        let body: Data
        do {
            body = try JSONCoding.encoder.encode(payload)
        } catch {
            callbackQueue.async { completion(.failure(NetworkError.encoding(error))) }
            return
        }

        provider.request(.create(body: body)) { [callbackQueue] result in
            callbackQueue.async {
                switch result {
                case .success(let response):
                    do {
                        let todo = try JSONCoding.decoder.decode(Todo.self, from: response.data)
                        completion(.success(todo))
                    } catch {
                        completion(.failure(NetworkError.decoding(error)))
                    }
                case .failure(let error):
                    completion(.failure(NetworkError.moya(error)))
                }
            }
        }
    }
    
    func update( /// PUT
        todo: Todo,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let payload = TodoUpsertPayload(title: todo.title, isDone: todo.isDone, createdAt: todo.createdAt)

        let body: Data
        do {
            body = try JSONCoding.encoder.encode(payload)
        } catch {
            callbackQueue.async { completion(.failure(NetworkError.encoding(error))) }
            return
        }

        provider.request(.update(id: todo.id, body: body)) { [callbackQueue] result in
            callbackQueue.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(NetworkError.moya(error)))
                }
            }
        }
    }
    
    func delete( /// DELETE
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )  {
        provider.request(.delete(id: id)) { [callbackQueue] result in
            callbackQueue.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(NetworkError.moya(error)))
                }
            }
        }
    }
    
}

